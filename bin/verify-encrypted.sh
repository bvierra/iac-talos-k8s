#!/usr/bin/env bash
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIR=$(realpath "${SCRIPT_DIR}/..")
BOOTSTRAP_DIR="${ROOT_DIR}/bootstrap"
KUBERNETES_DIR="${ROOT_DIR}/kubernetes"
TALOS_DIR="${ROOT_DIR}/talos"

source $ROOT_DIR/scripts/lib/common.sh


FILES=$(find "${BOOTSTRAP_DIR}" "${KUBERNETES_DIR}" "${TALOS_DIR}" -type f -name "*.sops.*" -print)

log info "Verifying encryption status of files..."

errors=0

function check_file() {
  local file=$1
  local status
  status=$(sops filestatus "$file" | jq ".encrypted")
  if [[ "$status" == "false" ]]; then
    log error "$file: NOT ENCRYPTED!"
    ((errors++))
  else
    log info "$file: Encrypted"
  fi
}

for file in $FILES; do
  check_file "$file"
done

if [[ $errors -ne 0 ]]; then
  log error "Encryption verification failed for $errors file(s). Please encrypt the files listed above."
  exit 1
else
  log info "All files are properly encrypted."
fi
