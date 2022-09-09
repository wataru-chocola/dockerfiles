#!/bin/bash

OLDIFS=$IFS
IFS=","
admins=(${SSH_ADMINISTRATORS})
IFS=$OLDIFS

for user in "${admins[@]}"; do
   echo "Adding $user to sudo"
   adduser "$user" sudo
   if [ $? -ne 0 ]; then
       echo "FATAL: Failed to update sudoers"
       exit 1
   fi
done