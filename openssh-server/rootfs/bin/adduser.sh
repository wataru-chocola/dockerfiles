#!/bin/bash

USER=$1

function addKey() {
    USER=$1
    while true
    do
        echo "enter your public key (press ENTER to proceed)>"
        read AUTHKEY
        if [ -n "${AUTHKEY}" ]
        then
            break
        fi
    done

    sudo -u "${USER}" sh -c "if [ ! -d ~/.ssh ]; then mkdir ~/.ssh && chmod 700 ~/.ssh; fi"
    [ $? -ne 0 ] && return 1
    echo "${AUTHKEY}\n" | sudo -u "${USER}" sh -c "tee -a ~/.ssh/authorized_keys"
    return $?
}

function setupOTP() {
    USER=$1
    sudo -u "${USER}" google-authenticator --time-based --no-confirm --disallow-reuse --no-rate-limit --window-size 17 --force
    return $?
}

function deleteUser() {
    USER=$1
    userdel --remove "${USER}"
    return $?
}

if [ -z "${USER}" ]; then
    echo "ERROR: MUST specify username"
    echo ""
    echo "  \$ $0 <username>"
    echo ""
    exit 1
fi

useradd --shell /bin/bash --create-home "${USER}"
if [ $? -ne 0 ]; then
    echo "FATAL: Failed to add a user"
    exit 1
fi

addKey "${USER}"
if [ $? -ne 0 ]; then
    echo "FATAL: Failed to add authorized_keys"
    deleteUser "${USER}"
    exit 1
fi

setupOTP "${USER}"
if [ $? -ne 0 ]; then
    echo "FATAL: Failed to setup OTP"
    deleteUser "${USER}"
    exit 1
fi