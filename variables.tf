variable "subnet_count" {
  type    = number
}
variable "availability_zones" {}

variable "cidr_block" {}

variable "public_subnet_cidr_blocks" {}

variable "private_subnet_cidr_blocks" {}

data "aws_caller_identity" "current" {}

