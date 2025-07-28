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

# SSH Security Group
resource "aws_security_group" "ssh_only" {
  name        = "${var.name}-ssh"
  description = "Allow SSH access from anywhere (IPv4 only)"
  vpc_id      = var.vpc_id

  ingress {
    description      = "SSH from anywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-ssh-sg"
  }
}

# Kubernetes Cluster Ports Security Group
resource "aws_security_group" "k8s_cluster" {
  name        = "${var.name}-k8s"
  description = "Security group for Kubernetes cluster communication"
  vpc_id      = var.vpc_id

  # Allow all traffic within this SG (node-to-node)
  ingress {
    description = "Allow all traffic within cluster"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  # Kubernetes API server
  ingress {
    description = "Kubernetes API"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Or restrict to admin IP
  }

  # etcd
  ingress {
    description = "etcd client communication"
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    self        = true
  }

  # kubelet API
  ingress {
    description = "kubelet API"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    self        = true
  }

  # NodePort Services
  ingress {
    description = "NodePort range"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress - Allow all
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-k8s-sg"
  }
}

# EC2 instances
resource "aws_instance" "this" {
  count         = var.instance_count
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  # Attach both SGs: SSH + Kubernetes
  vpc_security_group_ids = [
    aws_security_group.ssh_only.id,
    aws_security_group.k8s_cluster.id
  ]

  key_name = aws_key_pair.ec2_key.key_name

  tags = {
    Name = "${var.name}-${count.index}"
  }

  user_data = var.user_data
}
