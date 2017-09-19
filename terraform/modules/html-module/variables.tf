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