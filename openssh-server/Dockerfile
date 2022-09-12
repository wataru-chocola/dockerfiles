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

ADD data/init /init
RUN chmod 755 /init

ADD data/config/sshd_config /etc/ssh/sshd_config
ADD data/config/pam.d/sshd /etc/pam.d/sshd
ADD data/config/sudoers.d/sudo /etc/sudoers.d/sudo
RUN mkdir -p /etc/ssh/hostkeys

ADD data/bin /usr/local/bin
ADD data/init.d /init.d

EXPOSE 22
CMD ["/init"]
