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