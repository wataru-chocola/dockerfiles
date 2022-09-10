FROM debian:11-slim

ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

RUN apt update && apt install -y --no-install-recommends \
    openssh-server \
    libpam-google-authenticator \
    sudo \
    vim-tiny \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /etc/ssh/sshd_config \
 && rm -rf /etc/ssh/ssh_host_*_key*

RUN mkdir -p /run/sshd

ADD rootfs/init /init
RUN chmod 755 /init

ADD rootfs/config/sshd_config /etc/ssh/sshd_config
ADD rootfs/pam.d/sshd /etc/pam.d/sshd
RUN mkdir -p /etc/ssh/hostkeys
ADD rootfs/bin /usr/local/bin

ADD rootfs/init.d /init.d

EXPOSE 22
CMD ["/init"]
