#!/usr/bin/env bash

set -euo pipefail

REGION="${AWS_REGION:-sa-east-1}"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

require_command() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "ERROR: required command '$cmd' is not installed or not in PATH."
    exit 1
  fi
}

get_project_instances() {
  aws ec2 describe-instances \
    --region "$REGION" \
    --filters \
      "Name=tag:AutoPatch,Values=true" \
      "Name=instance-state-name,Values=running" \
    --query "Reservations[].Instances[].[InstanceId,Tags[?Key=='Name']|[0].Value,Tags[?Key=='PatchWave']|[0].Value,State.Name]" \
    --output text
}

get_ssm_ping_status() {
  local instance_id="$1"

  aws ssm describe-instance-information \
    --region "$REGION" \
    --filters "Key=InstanceIds,Values=${instance_id}" \
    --query "InstanceInformationList[0].PingStatus" \
    --output text 2>/dev/null || true
}

main() {
  require_command aws

  log "Validating SSM managed nodes in region ${REGION}"
  echo

  instances=$(get_project_instances)

  if [ -z "${instances}" ] || [ "${instances}" = "None" ]; then
    log "No running instances with AutoPatch=true were found."
    exit 0
  fi

  printf "%-20s %-25s %-12s %-12s %-12s\n" "INSTANCE_ID" "NAME" "PATCH_WAVE" "EC2_STATE" "SSM_STATUS"
  printf "%-20s %-25s %-12s %-12s %-12s\n" "--------------------" "-------------------------" "------------" "------------" "------------"

  while read -r instance_id name patch_wave ec2_state; do
    ssm_status=$(get_ssm_ping_status "$instance_id")

    if [ -z "${ssm_status}" ] || [ "${ssm_status}" = "None" ]; then
      ssm_status="NOT_REGISTERED"
    fi

    printf "%-20s %-25s %-12s %-12s %-12s\n" "$instance_id" "$name" "$patch_wave" "$ec2_state" "$ssm_status"
  done <<< "$instances"

  echo
  log "Validation complete."
}

main "$@"
