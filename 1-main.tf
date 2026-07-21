resource "aws_instance" "Rakesh" {
  count                  = var.Rakesh ? 1 : 0
  ami                    = local.ami_id
  instance_type          = var.instance_type
  subnet_id              = local.public_subnet_id
  vpc_security_group_ids = [aws_security_group.Sai-sg.id]
  user_data              = file("9-install.sh")


  root_block_device {
    volume_size = 50
    volume_type = "gp3"
    tags = merge(
      {
        Name = "${var.project}-${var.environment}-jenkins"
      },
      local.common_tags
    )
  }



  tags = merge(
    {
      Name = "${var.project}-${var.environment}-jenkins"
    },
    local.common_tags
  )
}

resource "aws_eip" "Rakesh" {
  count    = var.Rakesh ? 1 : 0
  domain   = "vpc"
  instance = aws_instance.Rakesh[count.index].id
}



resource "aws_instance" "jenkins_agent" {
  count                  = var.jenkins ? 1 : 0
  ami                    = local.ami_id
  instance_type          = "t3.micro"
  subnet_id              = local.public_subnet_id
  vpc_security_group_ids = [aws_security_group.Sai-sg.id]
  user_data              = file("10-jenkins-agent.sh")

  root_block_device {
    volume_size = 50
    volume_type = "gp3"
    tags = merge(
      {
        Name = "${var.project}-${var.environment}-jenkins-agent"
      },
      local.common_tags
    )
  }

  tags = merge(
    {
      Name = "${var.project}-${var.environment}-jenkins-agent"
    },
    local.common_tags
  )
}

resource "aws_instance" "runner" {
  count                  = var.runner ? 1 : 0
  ami                    = local.ami_id
  instance_type          = "t3.micro"
  subnet_id              = local.public_subnet_id
  vpc_security_group_ids = [aws_security_group.Sai-sg.id]
  user_data              = file("11-runner.sh")

  root_block_device {
    volume_size = 50
    volume_type = "gp3"
    tags = merge(
      {
        Name = "${var.project}-${var.environment}-runner"
      },
      local.common_tags
    )
  }

  tags = merge(
    {
      Name = "${var.project}-${var.environment}-runner"
    },
    local.common_tags
  )
}

resource "aws_instance" "sonarqube" {
  count                  = var.sonar ? 1 : 0
  ami                    = local.ami_id
  instance_type          = "t3.large"
  subnet_id              = local.public_subnet_id
  vpc_security_group_ids = [aws_security_group.Sai-sg.id]
  user_data = file("13-sonarqube.sh")

  root_block_device {
    volume_size = 150
    volume_type = "gp3"
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-sonarqube"
    }
  )
}


resource "aws_eip" "sonarqube" {
  count    = var.sonar ? 1 : 0
  domain   = "vpc"
  instance = aws_instance.sonarqube[count.index].id
}



# #sudo docker run -d \
# --name sonarqube \
# --network sonarqube \
# -p 9000:9000 \
# -e SONAR_JDBC_URL=jdbc:postgresql://postgres:5432/sonar \
# -e SONAR_JDBC_USERNAME=sonar \
# -e SONAR_JDBC_PASSWORD=sonar \
# sonarqube:lts

resource "aws_security_group" "Sai-sg" {
  name = "Sai-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
  from_port   = 9000
  to_port     = 9000
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Sai_sg"
  }
}


data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_route53_zone" "domain" {
  name         = var.domain_name
  private_zone = false
}





