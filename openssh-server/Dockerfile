FROM debian:11-slim

RUN apt update && apt install -y --no-install-recommends \
    openssh-server \
    libpam-google-authenticator \
    sudo \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /etc/ssh/sshd_config \
 && rm -rf /etc/ssh/ssh_host_*_keys*

RUN mkdir -p /run/sshd

ADD rootfs/init /init
RUN chmod 755 /init

ADD rootfs/config/sshd_config /etc/ssh/sshd_config
ADD rootfs/pam.d/sshd /etc/pam.d/sshd
RUN mkdir -p /etc/ssh/hostkeys

ADD rootfs/init.d /init.d

EXPOSE 22
CMD ["/init"]
