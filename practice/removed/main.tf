terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~>5.7.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

/* moved {
  from = aws_instance.ec2
  to = aws_instance.renamed_ec2

} */

/* resource "aws_instance" "ec2" {
  ami = "ami-0c398cb65a93047f2"
  instance_type = "t3.micro"
  tags = {
    Name = "removed-ec2"
  }
  
} */

/* resource "aws_instance" "renamed_ec2" {
  ami = "ami-0c398cb65a93047f2"
  instance_type = "t3.micro"
  tags = {
    Name = "removed-ec2"
  }
  
} */

# used removed block and destroy to false. the resource ec2 wont be managed by terraform, but wont destroy the real infrastructure.
/* removed {
  from = aws_instance.renamed_ec2
  lifecycle {
    destroy = false
  }
} */


# imported the removed renamed_ec2 back to import_ec2 by adding the below resource.
# but the tag name change will apply on the next terraform apply after terraform import.
resource "aws_instance" "import_ec2" {
    ami = "ami-0c398cb65a93047f2"
  instance_type = "t3.micro" 
  tags = {
    Name = "import-ec2"
  }
}