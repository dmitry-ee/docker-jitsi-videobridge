#!/bin/bash

set_config() {
    key="$1"
    value="$2"
    if grep -q "$key" "$config_tmp"; then
      sed_escaped_value="$(echo "$value" | sed 's/[\/&]/\\&/g')"
      sed -ri "s/^($key)[ ]*=.*$/\1=$sed_escaped_value/" "$config_tmp"
    else
      echo $'\r'"$key=$value" >> "$config_tmp"
    fi
}

if [ ! -z "$VERBOSE" ]; then
  printenv
  set -ex
fi

# maybe we'll make more command to do
if [[ "$1" == "start" ]]; then
  # config location
  sip_config_path=/etc/jitsi/videobridge/sip-communicator.properties

  # copy initial config
  config_tmp="$(mktemp)"
  cat $sip_config_path > $config_tmp

  # override some vars
  set_config  org.ice4j.ice.harvest.DISABLE_AWS_HARVESTER     $SC_HARVEST_DISABLE_AWS_HARVESTER
  set_config  org.ice4j.ice.harvest.STUN_MAPPING_HARVESTER_ADDRESSES  $SC_HARVEST_STUN_MAPPING_HARVESTER_ADDRESSES
  set_config  org.jitsi.videobridge.ENABLE_STATISTICS         $SC_VIDEOBRIDGE_ENABLE_STATISTICS
  set_config  org.jitsi.videobridge.STATISTICS_TRANSPORT      $SC_VIDEOBRIDGE_STATISTICS_TRANSPORT
  set_config  org.jitsi.videobridge.xmpp.user.shard.HOSTNAME  $SC_VIDEOBRIDGE_XMPP_USER_SHARD_HOSTNAME
  set_config  org.jitsi.videobridge.xmpp.user.shard.DOMAIN    $SC_VIDEOBRIDGE_XMPP_USER_SHARD_DOMAIN
  set_config  org.jitsi.videobridge.xmpp.user.shard.USERNAME  $SC_VIDEOBRIDGE_XMPP_USER_SHARD_USERNAME
  set_config  org.jitsi.videobridge.xmpp.user.shard.PASSWORD  $SC_VIDEOBRIDGE_XMPP_USER_SHARD_PASSWORD
  set_config  org.jitsi.videobridge.xmpp.user.shard.MUC_JIDS  $SC_VIDEOBRIDGE_XMPP_USER_SHARD_MUC_JIDS
  set_config  org.jitsi.videobridge.xmpp.user.shard.DISABLE_CERTIFICATE_VERIFICATION  $SC_VIDEOBRIDGE_XMPP_USER_SHARD_DISABLE_CERTIFICATE_VERIFICATION
  # dirty hack to generate unique string every run
  set_config  org.jitsi.videobridge.xmpp.user.shard.MUC_NICKNAME $(openssl rand -hex 36)

  # replace config
  cat "$config_tmp" > $sip_config_path
  rm "$config_tmp"

  # and finally... start
  cmd="/usr/share/jitsi-videobridge/jvb.sh --host=$XMPP_HOST --domain=$XMPP_DOMAIN --port=$XMPP_PORT --secret=$XMPP_SECRET --apis=$XMPP_APIS"
  echo $cmd
  exec $cmd
fi