FROM debian:buster-slim

ARG BUILD_PACKAGES="apt-transport-https gnupg2 wget"
ARG ESSENTIAL_PACKAGES="ca-certificates openssl"
ARG DUMB_INIT_VER=1.2.2

#   openjdk-11-jre-headless installation fails without /usr/share/man/man1 ¯\_(ツ)_/¯
RUN mkdir -p /usr/share/man/man1 && \
    apt update && apt install -y --no-install-recommends -q $ESSENTIAL_PACKAGES $BUILD_PACKAGES && \
    # jitsi-videobridge install
    echo 'deb https://download.jitsi.org stable/' >> /etc/apt/sources.list.d/jitsi-stable.list && \
    wget -qO -  https://download.jitsi.org/jitsi-key.gpg.key | apt-key add - && \
    apt update && apt install -y --no-install-recommends -q jitsi-videobridge2 && \
    # install dumb_init for proper SIG handling 
    wget https://github.com/Yelp/dumb-init/releases/download/v${DUMB_INIT_VER}/dumb-init_${DUMB_INIT_VER}_amd64.deb && \
    dpkg -i dumb-init_*.deb && \
    rm dumb-init_*.deb && \
    # cleanup
    apt remove --purge -y $BUILD_PACKAGES && \
    apt autoremove -y && \
    rm -rf /var/lib/apt/lists/*

ENV XMPP_SECRET=hello
ENV XMPP_DOMAIN=none
ENV XMPP_HOST=localhost
ENV XMPP_PORT=5347
ENV XMPP_APIS=xmpp,rest

ENV JAVA_SYS_PROPS="-Dnet.java.sip.communicator.SC_HOME_DIR_LOCATION=/etc/jitsi -Dnet.java.sip.communicator.SC_HOME_DIR_NAME=videobridge -Dnet.java.sip.communicator.SC_LOG_DIR_LOCATION=/var/log/jitsi -Djava.util.logging.config.file=/etc/jitsi/videobridge/logging.properties"

ENV SC_HARVEST_DISABLE_AWS_HARVESTER=true
ENV SC_HARVEST_STUN_MAPPING_HARVESTER_ADDRESSES=meet-jit-si-turnrelay.jitsi.net:443
ENV SC_VIDEOBRIDGE_ENABLE_STATISTICS=true
ENV SC_VIDEOBRIDGE_STATISTICS_TRANSPORT=muc
ENV SC_VIDEOBRIDGE_XMPP_USER_SHARD_HOSTNAME=hostname
ENV SC_VIDEOBRIDGE_XMPP_USER_SHARD_DOMAIN=domain
ENV SC_VIDEOBRIDGE_XMPP_USER_SHARD_USERNAME=username
ENV SC_VIDEOBRIDGE_XMPP_USER_SHARD_PASSWORD=password
ENV SC_VIDEOBRIDGE_XMPP_USER_SHARD_MUC_JIDS=muc_jids
ENV SC_VIDEOBRIDGE_XMPP_USER_SHARD_DISABLE_CERTIFICATE_VERIFICATION=true

ENV VIDEOBRIDGE_MAX_MEMORY=2048m

COPY docker-entrypoint.sh /
RUN  chmod +x docker-entrypoint.sh

ARG BUILD_DATE
ARG VERSION
LABEL maintainer="https://github.com/dmitry-ee"

VOLUME [ "/var/log/jitsi" ]

ENTRYPOINT [ "/usr/bin/dumb-init", "--" ]
CMD [ "/docker-entrypoint.sh", "start" ]