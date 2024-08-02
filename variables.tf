variable "region" {
  description = "AWS region"
  default     = "eu-west-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  description = "CIDR block for the public subnet"
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr_block" {
  description = "CIDR block for the private subnet"
  default     = "10.0.2.0/24"
}

variable "availability_zone" {
  description = "Availability zone"
  default     = "eu-west-1a"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "ami" {
  description = "AMI ID"
  default     = "ami-0c38b837cd80f13bb"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  default     = "kc-terraform-keypair"
}

variable "public_key_path" {
  description = "Path to the public key file"
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC9vds5NaJiHqAQ9H0E1VfFiseN9QqT0epIz3vPol6q+J1p8yyQBEJSSmXYD4LviLv85ISaKn2/942/9bz4Ogh608PoEYBM2sxKq2Vq/T5QNhFobdZXx6Pwtb5EYCVsj9mixT4Hn38bLsWek1uKWui04B6Tx33rhxc8kwJRs8rbQ0ZXj02by+YXG9+VB+B8GGNqw6kAKVj1BICGWMhMVF67cXQsF1x0+YAxELVxSaaKRh43I0MjBqAb18M6mtSgynElhxGqvdi8XAVoOB+k25iKlZL28U67ZFhtZd6qnKEXQkcsIcT6Hfj7yFFoPXn0zp5UtEGm2Ne8vbGD/80RgjrqeVaDAvokhYHsGKUgl4z12r3/A/Pdx+FOtKfRcKuZgZNdO8kHxEUe0+AJfAvK/TFVhBKkQJnNdigUPYkDx4EEaX7N9IvyDg0niLFWy8vnoLn5LkONil84b9NJFKhsyTUc4Sxf12hhLIYebGWbmtbPaLFBIaUiAb7VWWMaQHFJN68= bd_medsaf@OluwaJT"
}

variable "webserver_user_data" {
  description = "User data script for the public instance"
  default     = "./scripts/install_nginx.sh"
}

variable "dbserver_user_data" {
  description = "User data script for the private instance"
  default     = "./scripts/install_postgresql.sh"
}


