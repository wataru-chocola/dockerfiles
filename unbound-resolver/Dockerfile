FROM debian:11-slim

ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

RUN apt update && apt install -y --no-install-recommends unbound ca-certificates \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && rm -f /etc/unbound/unbound_control.* \
 && rm -f /etc/unbound/unbound_server.*

ADD data/init /init
RUN chmod 755 /init

ADD data/configs /etc/unbound/unbound.conf.d

ADD data/init.d /init.d

EXPOSE 53
CMD ["/init"]
