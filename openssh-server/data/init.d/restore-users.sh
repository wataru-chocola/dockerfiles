#!/bin/bash
#
# Restore user entries from /home directory.
#

HOMEDIR="/home"

OLDIFS=$IFS
IFS=","
admins=(${SSH_ADMINISTRATORS})
IFS=$OLDIFS

function isAdmin {
    local user
    user=$1
    for admin in "${admins[@]}"; do
        [[ $user = $admin ]] && return 0
    done
    return 1
}

for userdir in "${HOMEDIR}"/*
do
    [[ -d ${userdir} ]] || continue

    user=$(basename "$userdir")
    uid=$(stat -c "%u" "$userdir")
    gid=$(stat -c "%g" "$userdir")

    if isAdmin "$user"; then
        echo "Add admin user: ${user} (${uid})"
        useradd --shell /bin/bash --uid "${uid}" --user-group --home-dir "${userdir}" --groups sudo "${user}"
        if [ $? -ne 0 ]; then
            echo "FATAL: Failed to restore a user"
            exit 1
        fi
    else
        echo "Add user: ${user} (${uid})"
        useradd --shell /bin/bash --uid "${uid}" --user-group --home-dir "${userdir}" "${user}"
        if [ $? -ne 0 ]; then
            echo "FATAL: Failed to restore a user"
            exit 1
        fi
    fi
done