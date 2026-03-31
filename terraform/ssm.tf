resource "aws_ssm_patch_baseline" "linux" {
  name             = "${var.project_name}-${var.patch_group}-baseline"
  description      = "Patch baseline for Linux instances in the patch management demo"
  operating_system = "AMAZON_LINUX_2"

  approval_rule {
    approve_after_days = 7
    compliance_level   = "CRITICAL"

    patch_filter {
      key    = "CLASSIFICATION"
      values = ["Security", "Bugfix", "Critical"]
    }

    patch_filter {
      key    = "SEVERITY"
      values = ["Critical", "Important"]
    }
  }

  approved_patches_enable_non_security = false

  tags = {
    Name = "${var.project_name}-${var.patch_group}-baseline"
  }
}

resource "aws_ssm_patch_group" "linux_prod" {
  baseline_id = aws_ssm_patch_baseline.linux.id
  patch_group = var.patch_group
}
