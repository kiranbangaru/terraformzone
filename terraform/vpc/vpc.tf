##################################################################################
# VARIABLES
##################################################################################

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}
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

resource "aws_vpc" "main" {
  cidr_block  = "10.0.0.0/16"

  tags {
    Name = "main"
  }
}

resource "aws_subnet" "public"{
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2a"
  tags {
    Name = "public"
  }
}

#resource "aws_network_interface" "foo" {
#  subnet_id = "${aws_subnet.public.id}"
#  private_ips = ["10.0.10.5"]
#  tags {
#    Name = "primary_network_interface"
#  }
#}

resource "aws_security_group" "apache-sg"{
  name        = "VPCSecurityGroup"
  description = "Security Group for within the VPC"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "apache-sg"
  }

}
resource "aws_instance" "apache2"{
  ami           = "ami-6e1a0117"
  instance_type = "t2.micro"
 #  network_interface {
 #    network_interface_id = "${aws_network_interface.foo.id}"
  #   device_index = 0
 #subnet_id     = "${aws_subnet.public.id}"
  vpc_security_group_ids  = ["${aws_security_group.apache-sg.id}"]
  #}
  key_name      = "${var.key_name}"
  
  connection {
    user        = "ubuntu"
    private_key = "${file(var.private_key_path)}"
  }

  tags {
    Name = "apache-ubuntu"
  }
  provisioner "remote-exec"{
    inline = [
      #"sudo apt-get update"
      "sudo apt-get install apache2 -y"
    ]
  }
}

##################################################################################
# OUTPUT
##################################################################################

output "aws_instance.apache2.public_ip"{
   value = "${aws_instance.apache2.public_ip}"
}

