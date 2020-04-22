#!/bin/bash
docker run -d --rm --name jitsi-videobridge \
  --network=host -m 2048m \
  -e VERBOSE=true \
  -e XMPP_SECRET=somevalue \
  -e XMPP_DOMAIN=none \
  -e XMPP_HOST=localhost \
  -e XMPP_PORT=5000 \
  -e XMPP_APIS=xmpp,rest \
  -e SC_HARVEST_DISABLE_AWS_HARVESTER=true \
  -e SC_HARVEST_STUN_MAPPING_HARVESTER_ADDRESSES=meet-jit-si-turnrelay.jitsi.net:443 \
  -e SC_VIDEOBRIDGE_ENABLE_STATISTICS=true \
  -e SC_VIDEOBRIDGE_STATISTICS_TRANSPORT=muc \
  -e SC_VIDEOBRIDGE_XMPP_USER_SHARD_HOSTNAME=somevalue \
  -e SC_VIDEOBRIDGE_XMPP_USER_SHARD_DOMAIN=somevalue \
  -e SC_VIDEOBRIDGE_XMPP_USER_SHARD_USERNAME=somevalue \
  -e SC_VIDEOBRIDGE_XMPP_USER_SHARD_PASSWORD=somevalue \
  -e SC_VIDEOBRIDGE_XMPP_USER_SHARD_MUC_JIDS=somevalue \
  -e SC_VIDEOBRIDGE_XMPP_USER_SHARD_DISABLE_CERTIFICATE_VERIFICATION=true \
  -e VIDEOBRIDGE_MAX_MEMORY=2048m \
  dmi7ry/jitsi-videobridge:latest

docker run -d --rm --name jitsi-videobridge-exporter \
  --network=host \
  -e EXPORTER_URL=http://localhost:8080/colibri/stats \
  dmi7ry/jitsi-videobridge-exporter:latest