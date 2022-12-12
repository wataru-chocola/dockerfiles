SERVER_KEY=/etc/unbound/unbound_server.key
SERVER_PEM=/etc/unbound/unbound_server.pem

if [ -f "${SERVER_KEY}" ] && [ -f "${SERVER_PEM}" ]; then
    exit 0
elif [ ! -f "${SERVER_KEY}" ] && [ ! -f "${SERVER_PEM}" ]; then
    /usr/sbin/unbound-control-setup
    exit 0
else
    echo "FAILED: found incomplete pair of server key"
    exit 1
fi
