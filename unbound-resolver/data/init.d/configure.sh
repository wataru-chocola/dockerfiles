#!/bin/bash
#
# Load user config
#

USER_CONFIG_DIR="/config"
UNBOUND_CONFIG_DIR="/etc/unbound/unbound.conf.d/"

[[ -d "${USER_CONFIG_DIR}" ]] || exit 0

for conffile in "${USER_CONFIG_DIR}"/*
do
  [[ -f "${conffile}" ]] || continue

  filename=$(basename "$conffile")
  if [[ -f "${UNBOUND_CONFIG_DIR%%/}/${filename}" ]]
  then
    echo "Override config file: ${filename}"
  else
    echo "Add config file: ${filename}"
  fi
  cp "${conffile}" "${UNBOUND_CONFIG_DIR}"
done