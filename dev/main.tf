provider "aws" {
  region = "ap-south-1"
}



module "vpc" {
  source                = "../modules/vpc"
  cidr_block            = "10.10.0.0/16"
  
  name                  = "dev-vpc"
  public_subnet_cidr_a  = "10.10.1.0/24"
  public_subnet_cidr_b  = "10.10.2.0/24"
  private_subnet_cidr_a  = "10.10.3.0/24"
  private_subnet_cidr_b  = "10.10.4.0/24"
  availability_zone_a   = "us-east-1a"
  availability_zone_b   = "us-east-1b"
}



module "ec2_dev" {
  source         = "../modules/ec2"
  ami_id         = "ami-084568db4383264d4"
  instance_type  = "t2.medium"
  subnet_id      = module.vpc.public_subnet_ids[0] # pick first subnet
  name           = "cluster"
  instance_count = 1
  vpc_id         = module.vpc.vpc_id 

}

