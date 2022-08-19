
# EC2
resource "aws_instance" "EC2_1" {
   count = var.instance_quantity
    key_name = "terra-key"
    ami = "ami-08d4ac5b634553e16" #Choice -> Have to select image Ubuntu 
    instance_type = "t2.micro" #Choice -> Have to select instance type (t2.micro, t2.nano, etc)
    subnet_id = aws_subnet.public_subnets[count.index].id
    vpc_security_group_ids = [ aws_security_group.security_group_http.id ]

    tags = {
      Name = "EC2-${count.index}-${local.common_tags.Project}"
    }

  connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = file("./terra-key.pem")
      host     = self.public_ip
  }

      provisioner "remote-exec" {
        inline = [
            "sudo apt-get update -y",
            "sudo apt-get dist-upgrade -y",
            "sudo apt-get autoremove",
            "sudo apt-get install -y ca-certificates curl gnupg lsb-release",
            "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
            "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
            "sudo apt-get update -y",
            "sudo apt-get install docker-ce docker-ce-cli containerd.io -y",
            "sudo docker run -it -d oktaadmin/oktaonprem"
        ]
    }
}

output "IP" {
  value = aws_instance.EC2_1[0].public_ip  
}
