module "aws-instance" {
    
    source = "../../modules/EC2-instance"
    ubuntu2204-ami = "ami-0c398cb65a93047f2"
    instance-type = "t3.micro"
    key-name = "mylinux"
    ec2-name = "vault-ec2"
    
    

  
}

output "ec2-public-ip" {
    value = module.aws-instance.ec2-pub-ip
  
}