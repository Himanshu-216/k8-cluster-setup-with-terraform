# Key Pair + Private Key
resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2_key" {
  key_name   = "${var.name}-key"
  public_key = tls_private_key.ec2_key.public_key_openssh
}

resource "local_file" "private_key_pem" {
  content              = tls_private_key.ec2_key.private_key_pem
  filename             = "${path.module}/${var.name}-key.pem"
  file_permission      = "0600"
  directory_permission = "0700"
}

# SSH SG
resource "aws_security_group" "ssh_only" {
  name        = "${var.name}-ssh"
  description = "Allow SSH access"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name}-ssh-sg" }
}

# Master SG (API, etcd, kubelet, intra-cluster)
resource "aws_security_group" "master_sg" {
  name        = "${var.name}-master"
  description = "Control plane SG"
  vpc_id      = var.vpc_id

  ingress {
    description = "Kubernetes API"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict in prod!
  }

  ingress {
    description = "etcd client communication"
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "kubelet API"
    from_port   = 10249
    to_port     = 10259
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "Node-to-node communication"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "NodePort range"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name}-master-sg" }
}

# Worker SG (NodePort, intra-worker)
resource "aws_security_group" "worker_sg" {
  name        = "${var.name}-worker"
  description = "Worker node SG"
  vpc_id      = var.vpc_id

  # NodePort Services
  ingress {
    description = "NodePort range"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow intra-worker communication
  ingress {
    description = "Worker to Worker"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name}-worker-sg" }
}

# Weave Net Rules (shared by master + worker)
resource "aws_security_group_rule" "weavenet_tcp" {
  description              = "Weave Net TCP control traffic"
  type                     = "ingress"
  from_port                = 6783
  to_port                  = 6783
  protocol                 = "tcp"
  self                     = true
  security_group_id        = aws_security_group.master_sg.id
}

resource "aws_security_group_rule" "weavenet_udp_master" {
  description              = "Weave Net UDP data traffic"
  type                     = "ingress"
  from_port                = 6783
  to_port                  = 6784
  protocol                 = "udp"
  self                     = true
  security_group_id        = aws_security_group.master_sg.id
}

resource "aws_security_group_rule" "weavenet_tcp_worker" {
  description              = "Weave Net TCP control traffic"
  type                     = "ingress"
  from_port                = 6783
  to_port                  = 6783
  protocol                 = "tcp"
  self                     = true
  security_group_id        = aws_security_group.worker_sg.id
}

resource "aws_security_group_rule" "weavenet_udp_worker" {
  description              = "Weave Net UDP data traffic"
  type                     = "ingress"
  from_port                = 6783
  to_port                  = 6784
  protocol                 = "udp"
  self                     = true
  security_group_id        = aws_security_group.worker_sg.id
}

# Master EC2 Instances
resource "aws_instance" "masters" {
  count         = var.master_count
  ami           = var.ami_id
  instance_type = var.master_instance_type
  subnet_id     = var.subnet_id

  vpc_security_group_ids = [
    aws_security_group.ssh_only.id,
    aws_security_group.master_sg.id
  ]

  key_name = aws_key_pair.ec2_key.key_name

  tags = { Name = "${var.name}-master-${count.index}" }

  user_data = var.master_user_data
}

# Worker EC2 Instances
resource "aws_instance" "workers" {
  count         = var.worker_count
  ami           = var.ami_id
  instance_type = var.worker_instance_type
  subnet_id     = var.subnet_id

  vpc_security_group_ids = [
    aws_security_group.ssh_only.id,
    aws_security_group.worker_sg.id
  ]

  key_name = aws_key_pair.ec2_key.key_name

  tags = { Name = "${var.name}-worker-${count.index}" }

  user_data = var.worker_user_data
}
