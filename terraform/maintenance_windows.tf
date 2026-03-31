resource "aws_iam_role" "ssm_maintenance_window_service_role" {
  name = "${var.project_name}-ssm-mw-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ssm.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-ssm-mw-service-role"
  }
}

resource "aws_iam_role_policy_attachment" "ssm_maintenance_window_service_role_attachment" {
  role       = aws_iam_role.ssm_maintenance_window_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMMaintenanceWindowRole"
}

resource "aws_ssm_maintenance_window" "patching" {
  name                       = "${var.project_name}-patch-window"
  description                = "Maintenance window for EC2 patching"
  schedule                   = "cron(0 3 ? * SUN *)"
  duration                   = 4
  cutoff                     = 1
  allow_unassociated_targets = false

  tags = {
    Name = "${var.project_name}-patch-window"
  }
}

resource "aws_ssm_maintenance_window_target" "patch_target" {
  window_id     = aws_ssm_maintenance_window.patching.id
  name          = "${var.project_name}-patch-target"
  description   = "Target EC2 instances with AutoPatch enabled"
  resource_type = "INSTANCE"

  targets {
    key    = "tag:AutoPatch"
    values = ["true"]
  }
}

resource "aws_ssm_maintenance_window_task" "patch_install" {
  window_id        = aws_ssm_maintenance_window.patching.id
  name             = "${var.project_name}-run-patch-baseline"
  description      = "Run patch baseline installation on tagged EC2 instances"
  priority         = 1
  max_concurrency  = "1"
  max_errors       = "1"
  task_type        = "RUN_COMMAND"
  task_arn         = "AWS-RunPatchBaseline"
  service_role_arn = aws_iam_role.ssm_maintenance_window_service_role.arn

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.patch_target.id]
  }

  task_invocation_parameters {
    run_command_parameters {
      parameter {
        name   = "Operation"
        values = ["Install"]
      }
    }
  }
}
