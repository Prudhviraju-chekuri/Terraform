resource "aws_instance" "variables-ec2" {
    ami = var.ubuntu2204-ami
    instance_type = var.instance-type
    key_name = var.key-name
    tags = {
      Name = var.ec2-name
    }
 
}