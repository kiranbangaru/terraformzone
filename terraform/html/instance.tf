##################################################################################
# VARIABLES
##################################################################################

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}
variable "environment" {
  default = "dev"
}
variable "key_name" {
  default = "keypair"
}

##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "us-west-2"
}

##################################################################################
# RESOURCES
##################################################################################

resource "aws_instance" "web" {
  ami           = "ami-aa5ebdd2"
  instance_type = "t2.micro"
  key_name        = "${var.key_name}"

  connection {
    user        = "ec2-user"
    private_key = "${file(var.private_key_path)}"
  }

  provisioner "file" {
   source      = "${var.environment}/index.html"
   destination = "/home/ec2-user/index.html"  
  }
  
  provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd -y",
      "sudo service httpd start",
    ]
    connection {
      type = "ssh"
      user    = "ec2-user"
      private_key = "${file(var.private_key_path)}"
    } 
  }

  
  
  #provisioner "local-exec" {
  #       command = "scp -i ${file(var.private_key_path)} /${var.environment}/index.html ec2-user@${aws_instance.web.public_dns}:/home/ec2-user"
  #}
  
  provisioner "remote-exec" {
    inline = [
      "sudo chmod 777 /var/www/html",
      "sudo cp /home/ec2-user/index.html /var/www/html/",
      "sudo service httpd restart",
    ]  
     connection {
       type = "ssh"
       user    = "ec2-user"
       private_key = "${file(var.private_key_path)}"
    }    
  }
}

##################################################################################
# OUTPUT
##################################################################################

output "aws_instance_public_dns" {
    value = "${aws_instance.web.public_dns}"
}