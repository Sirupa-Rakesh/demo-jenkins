locals {
  ami_id = var.ami_id

  common_tags = {
    Project     = var.project
    Environment = var.environment
    Terraform   = "true"
  }

  # public subnet in default VPC
  public_subnet_id = data.aws_subnets.default.ids[0]
}