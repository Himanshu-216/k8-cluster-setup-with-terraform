provider "aws" {
  region = "us-east-1"
}

# --- VPC Module ---
module "vpc" {
  source                = "../modules/vpc"
  cidr_block            = "10.10.0.0/16"
  
  name                  = "k8-vpc"
  public_subnet_cidr_a  = "10.10.1.0/24"
  public_subnet_cidr_b  = "10.10.2.0/24"
  private_subnet_cidr_a = "10.10.3.0/24"
  private_subnet_cidr_b = "10.10.4.0/24"
  availability_zone_a   = "us-east-1a"
  availability_zone_b   = "us-east-1b"
}

# --- EC2 Module (Masters + Workers) ---
module "ec2_cluster" {
  source = "../modules/ec2"

  # EC2 common
  ami_id = "ami-084568db4383264d4"
  vpc_id = module.vpc.vpc_id
  name   = "cluster"

  # Subnet placement → choose public subnet for now
  subnet_id = module.vpc.public_subnet_ids[0]

  # Master nodes
  master_count         = var.master_count
  master_instance_type = var.master_instance_type
  master_user_data     = file("/home/himanshu/terraform-basic/modules/scripts/master.sh")

  # Worker nodes
  worker_count         = var.worker_count
  worker_instance_type = var.worker_instance_type
  worker_user_data     = file("/home/himanshu/terraform-basic/modules/scripts/worker.sh")
}
