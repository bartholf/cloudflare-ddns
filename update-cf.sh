#!/bin/bash
API_BASE_URI=https://api.cloudflare.com/client/v4
CURR_IP="$(dig +short myip.opendns.com @resolver1.opendns.com)"
DIR="$(dirname ${BASH_SOURCE[0]})"
IP_FILE=$DIR/ip
OLD_IP=$([ -f "$IP_FILE" ] && echo $(cat $IP_FILE) || echo 'EMPTY')

source $DIR/.env

if [[ $CURR_IP == $OLD_IP ]]; then
    echo 'Nothing to do..'
    exit 0
fi

api_get() {
    echo $(curl -s -X GET "$API_BASE_URI/$1" \
        -H "X-Auth-Email: $CF_EMAIL" \
        -H "X-Auth-Key: $CF_TOKEN" \
        -H "Content-Type: application/json") | jq -r $2
}

# get the zone id for the requested zone
ZONE_ID=$(api_get "zones?name=$ZONE_NAME&status=active" '.result[0].id')

# Get the A record id
A_ID=$(api_get "zones/$ZONE_ID/dns_records?name=$ZONE_NAME&type=A" '.result[0].id')

# Update record
RES=$(curl -s -X PUT "$API_BASE_URI/zones/$ZONE_ID/dns_records/$A_ID" \
    -H "X-Auth-Email: $CF_EMAIL" \
    -H "X-Auth-Key: $CF_TOKEN" \
    -H "Content-Type: application/json" --data "{\"id\":\"$ZONE_ID\",\"type\":\"A\",\"name\":\"$ZONE_NAME\",\"content\":\"$CURR_IP\"}" | jq '.success')

if [[ $RES ]]; then
    echo $CURR_IP > $IP_FILE
    MSG="DDNS New IP $CURR_IP"
    echo $MSG
    logger $MSG
    exit 0
fi

exit 1
