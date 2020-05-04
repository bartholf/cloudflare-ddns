#!/bin/bash
CURR_IP="$(dig +short myip.opendns.com @resolver1.opendns.com)"
DIR="$(dirname ${BASH_SOURCE[0]})"
IP_FILE=$DIR/ip
OLD_IP=$([ -f "$IP_FILE" ] && echo $(cat $IP_FILE) || echo 'EMPTY')

source $DIR/.env

if [[ $CURR_IP == $OLD_IP ]]; then
    echo 'Nothing to do..'
    exit 0
fi

# get the zone id for the requested zone
ZONE_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$ZONE_NAME&status=active" \
    -H "X-Auth-Email: $CF_EMAIL" \
    -H "X-Auth-Key: $CF_TOKEN" \
    -H "Content-Type: application/json" | jq -r '.result[0].id')

# Get the id for the A pointer of the DNS record whose name matches ZONE_NAME
A_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?name=$ZONE_NAME&type=A" \
    -H "X-Auth-Email: $CF_EMAIL" \
    -H "X-Auth-Key: $CF_TOKEN" \
    -H "Content-Type: application/json" | jq -r '.result[0].id')

# Update record
RES=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$A_ID" \
    -H "X-Auth-Email: $CF_EMAIL" \
    -H "X-Auth-Key: $CF_TOKEN" \
    -H "Content-Type: application/json" --data "{\"id\":\"$ZONE_ID\",\"type\":\"A\",\"name\":\"$ZONE_NAME\",\"content\":\"$CURR_IP\"}" | jq '.success')

if [[ $RES ]]; then
    echo $CURR_IP > $IP_FILE
    logger "DDNS New IP $CURR_IP"
    exit 0
fi

exit 1
