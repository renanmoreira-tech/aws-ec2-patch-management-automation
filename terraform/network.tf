data "aws_subnet" "az1" {
  id = var.subnet_id_az1
}

data "aws_subnet" "az2" {
  id = var.subnet_id_az2
}

data "aws_subnet" "az3" {
  id = var.subnet_id_az3
}
