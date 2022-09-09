HOSTKEYS_DIR=/etc/ssh/hostkeys

[ -d ${HOSTKEYS_DIR} ] || mkdir -p ${HOSTKEYS_DIR}

[ -f ${HOSTKEYS_DIR}/ssh_host_rsa_key ] || ssh-keygen -t rsa -f ${HOSTKEYS_DIR}/ssh_host_rsa_key -N ""
[ -f ${HOSTKEYS_DIR}/ssh_host_ecdsa_key ] || ssh-keygen -t ecdsa -f ${HOSTKEYS_DIR}/ssh_host_ecdsa_key -N ""
[ -f ${HOSTKEYS_DIR}/ssh_host_ed25519_key ] || ssh-keygen -t ed25519 -f ${HOSTKEYS_DIR}/ssh_host_ed25519_key -N ""