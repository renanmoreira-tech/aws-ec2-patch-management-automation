#!/usr/bin/env bash

set -euo pipefail

REGION="${AWS_REGION:-sa-east-1}"
WAVES=("1" "2" "3")
DOCUMENT_NAME="AWS-RunPatchBaseline"
OPERATION="Install"
SLEEP_SECONDS=10

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

get_instance_ids_by_wave() {
  local wave="$1"

  aws ec2 describe-instances \
    --region "$REGION" \
    --filters \
      "Name=tag:AutoPatch,Values=true" \
      "Name=tag:PatchWave,Values=${wave}" \
      "Name=instance-state-name,Values=running" \
    --query "Reservations[].Instances[].InstanceId" \
    --output text
}

wait_for_ssm_online() {
  local instance_id="$1"
  local max_attempts=30
  local attempt=1

  while [ "$attempt" -le "$max_attempts" ]; do
    local ping_status
    ping_status=$(aws ssm describe-instance-information \
      --region "$REGION" \
      --filters "Key=InstanceIds,Values=${instance_id}" \
      --query "InstanceInformationList[0].PingStatus" \
      --output text 2>/dev/null || true)

    if [ "$ping_status" = "Online" ]; then
      log "Instance ${instance_id} is Online in SSM."
      return 0
    fi

    log "Waiting for instance ${instance_id} to become Online in SSM... attempt ${attempt}/${max_attempts}"
    sleep "$SLEEP_SECONDS"
    attempt=$((attempt + 1))
  done

  log "ERROR: instance ${instance_id} did not become Online in SSM."
  return 1
}

send_patch_command() {
  local wave="$1"

  aws ssm send-command \
    --region "$REGION" \
    --document-name "$DOCUMENT_NAME" \
    --targets "Key=tag:PatchWave,Values=${wave}" "Key=tag:AutoPatch,Values=true" \
    --parameters "Operation=${OPERATION}" \
    --comment "Patch wave ${wave}" \
    --query "Command.CommandId" \
    --output text
}

wait_for_command_on_instance() {
  local command_id="$1"
  local instance_id="$2"

  aws ssm wait command-executed \
    --region "$REGION" \
    --command-id "$command_id" \
    --instance-id "$instance_id"
}

get_command_status() {
  local command_id="$1"
  local instance_id="$2"

  aws ssm get-command-invocation \
    --region "$REGION" \
    --command-id "$command_id" \
    --instance-id "$instance_id" \
    --query "Status" \
    --output text
}

validate_instance_running() {
  local instance_id="$1"

  local state
  state=$(aws ec2 describe-instances \
    --region "$REGION" \
    --instance-ids "$instance_id" \
    --query "Reservations[].Instances[].State.Name" \
    --output text)

  if [ "$state" != "running" ]; then
    log "ERROR: instance ${instance_id} is not in running state. Current state: ${state}"
    return 1
  fi

  log "Instance ${instance_id} is in running state."
}

main() {
  require_command aws

  log "Starting patch orchestration in region ${REGION}"

  for wave in "${WAVES[@]}"; do
    log "============================================================"
    log "Starting patch wave ${wave}"

    instance_ids=$(get_instance_ids_by_wave "$wave")

    if [ -z "${instance_ids}" ] || [ "${instance_ids}" = "None" ]; then
      log "No running instances found for wave ${wave}. Skipping."
      continue
    fi

    log "Instances in wave ${wave}: ${instance_ids}"

    for instance_id in ${instance_ids}; do
      wait_for_ssm_online "$instance_id"
    done

    command_id=$(send_patch_command "$wave")
    log "Patch command sent for wave ${wave}. Command ID: ${command_id}"

    for instance_id in ${instance_ids}; do
      log "Waiting for patch command on instance ${instance_id}"
      wait_for_command_on_instance "$command_id" "$instance_id"

      status=$(get_command_status "$command_id" "$instance_id")
      log "Patch status for instance ${instance_id}: ${status}"

      if [ "$status" != "Success" ]; then
        log "ERROR: patch failed on instance ${instance_id}. Stopping rollout."
        exit 1
      fi

      validate_instance_running "$instance_id"
      wait_for_ssm_online "$instance_id"
    done

    log "Wave ${wave} completed successfully."
  done

  log "============================================================"
  log "All patch waves completed successfully."
}

main "$@"
