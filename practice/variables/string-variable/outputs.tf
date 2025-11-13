output "ec2-pub-ip" {
    value = aws_instance.variables-ec2.public_ip
  
}