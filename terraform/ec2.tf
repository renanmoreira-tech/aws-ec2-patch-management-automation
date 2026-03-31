locals {
  instances = {
    app_az1 = {
      name       = "app-prod-az1"
      subnet_id  = var.subnet_id_az1
      patch_wave = "1"
    }
    app_az2 = {
      name       = "app-prod-az2"
      subnet_id  = var.subnet_id_az2
      patch_wave = "2"
    }
    app_az3 = {
      name       = "app-prod-az3"
      subnet_id  = var.subnet_id_az3
      patch_wave = "3"
    }
  }
}

resource "aws_instance" "app" {
  for_each = local.instances

  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = each.value.subnet_id
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_ssm_instance_profile.name
  associate_public_ip_address = true
  key_name                    = var.key_name != "" ? var.key_name : null

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name       = each.value.name
    Role       = "app"
    AutoPatch  = "true"
    PatchGroup = "linux-prod"
    PatchWave  = each.value.patch_wave
  }
}
