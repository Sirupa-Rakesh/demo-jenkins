variable "region" {
  default = "us-east-1"
}
variable "ami_id" {
  default = "ami-0220d79f3f480ecf5"
}
variable "instance_type" {
  default = "t3.micro"
}
variable "domain_name" {
  default = "rakeshdev.online"
}

variable "subdomain" {
  default = "sai"

}

variable "project" {
  default = "Rakesh"

}

variable "environment" {
  default = "dev"

}

variable "create_jenkins" {
  type    = bool
  default = true
}

variable "Rakesh" {
  default = true

}

variable "sonar" {
  default = true
}

variable "jenkins" {
  default = true
}

variable "runner" {
  default = false
}