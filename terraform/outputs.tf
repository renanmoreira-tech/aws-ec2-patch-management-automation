output "ec2_instance_ids" {
  description = "IDs of the EC2 instances created for the patch management demo"
  value       = { for key, instance in aws_instance.app : key => instance.id }
}

output "ec2_private_ips" {
  description = "Private IP addresses of the EC2 instances"
  value       = { for key, instance in aws_instance.app : key => instance.private_ip }
}

output "ec2_public_ips" {
  description = "Public IP addresses of the EC2 instances"
  value       = { for key, instance in aws_instance.app : key => instance.public_ip }
}

output "ec2_instance_names" {
  description = "Name tags of the EC2 instances"
  value       = { for key, instance in aws_instance.app : key => instance.tags["Name"] }
}

output "ec2_ssm_role_name" {
  description = "IAM role name attached to the EC2 instances for Systems Manager"
  value       = aws_iam_role.ec2_ssm_role.name
}

output "ec2_ssm_instance_profile_name" {
  description = "IAM instance profile used by the EC2 instances"
  value       = aws_iam_instance_profile.ec2_ssm_instance_profile.name
}

output "ssm_patch_baseline_id" {
  description = "ID of the SSM patch baseline"
  value       = aws_ssm_patch_baseline.linux.id
}

output "ssm_patch_group" {
  description = "Patch group associated with the SSM patch baseline"
  value       = aws_ssm_patch_group.linux_prod.patch_group
}

output "ssm_maintenance_window_id" {
  description = "ID of the SSM maintenance window"
  value       = aws_ssm_maintenance_window.patching.id
}

output "ssm_maintenance_window_name" {
  description = "Name of the SSM maintenance window"
  value       = aws_ssm_maintenance_window.patching.name
}

output "ssm_maintenance_window_target_id" {
  description = "ID of the SSM maintenance window target"
  value       = aws_ssm_maintenance_window_target.patch_target.id
}

output "ssm_maintenance_window_task_id" {
  description = "ID of the SSM maintenance window patch task"
  value       = aws_ssm_maintenance_window_task.patch_install.id
}
