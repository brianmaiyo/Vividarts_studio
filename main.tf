terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.7.0"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAWJ2SD35ONHZHVI5X"
  secret_key = "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"
}

#Creating a VPC
resource "aws_vpc" "my_prod_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "production_vpc"
  }

}

#Subnet within my prod VPC
resource "aws_subnet" "main_subnet" {
  vpc_id     = aws_vpc.my_prod_vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "production_subnet"
  }
}


#Gateway for production VPC
resource "aws_internet_gateway" "prod_gateway" {
  vpc_id = aws_vpc.my_prod_vpc.id

  tags = {
    Name = "production_gateway"
  }
}

#A route table for the VPC created
resource "aws_route_table" "prod_route_table" {
  vpc_id = aws_vpc.my_prod_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prod_gateway.id
  }

  
  tags = {
    Name = "production_routes"
  }
}

#New subnet for the route table
resource "aws_subnet" "secondary_subnet" {
  vpc_id            = aws_vpc.my_prod_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "prod_secondary_subnet"
  }
}

#Route table association to link the route table to the subnet
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.secondary_subnet.id
  route_table_id = aws_route_table.prod_route_table.id
}

#Security group for the created resources
resource "aws_security_group" "allow_web_traffic" {
  name        = "allow_web_traffic"
  description = "Allow TLS inbound traffic for prod"
  vpc_id      = aws_vpc.my_prod_vpc.id

  ingress {
    description      = "HTTPS traffic"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "HTTP traffic"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "SSH traffic"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_all_web_traffic"
  }
}

#A network interface to link an IP to the created subnet.Provate IP address for the host
resource "aws_network_interface" "provisioned_resources" {
  subnet_id       = aws_subnet.secondary_subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web_traffic.id]

}

#Public IP address for the rest
# resource "aws_eip" "one" {
#   domain                    = "vpc"
#   network_interface         = aws_network_interface.provisioned_resources.id
#   associate_with_private_ip = "10.0.1.50"
#   depends_on                = [aws_internet_gateway.prod_gateway]
# }

# output "my_public_IP" {
#   value = aws_eip.one.public_ip

# }

#Creating an Ubuntu server instance (EC2)
resource "aws_instance" "web_server_prod" {
  ami               = "ami-053b0d53c279acc90"
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.provisioned_resources.id
  }

  tags = {
    Name = "Prod_web_server"
  }
}

resource "aws_s3_bucket" "vividstudiobucket9876" {
    bucket = "vividstudiobucket9876"
    tags = {
      Environment = "production" 
    } 
  
}

resource "aws_s3_bucket_lifecycle_configuration" "vividstudiobucket9876" {
    bucket = aws_s3_bucket.vividstudiobucket9876.id
    
    rule {
        id = "uploads"
        expiration {
          days = 90
        }        
        filter {
          and {
            prefix = "uploads/"
          }
        }
        status = "Enabled"
        transition {
          days =  60
          storage_class = "GLACIER"
        }
        
    }  
}

resource "aws_cloudwatch_metric_alarm" "vividarts_studio_metrics" {
  alarm_name                = "vividarts_studio_metrics"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 120
  statistic                 = "Average"
  threshold                 = 80
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []
}

