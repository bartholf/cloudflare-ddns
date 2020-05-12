#!/bin/bash
DIR="$(dirname ${BASH_SOURCE[0]})"
IP_FILE=$DIR/ip
OLD_IP=$([ -f "$IP_FILE" ] && echo $(cat $IP_FILE) || echo 'EMPTY')

source $DIR/.env

if [[ $CURR_IP == $OLD_IP ]]; then
    echo 'Nothing to do..'
    exit 0
fi

api_call() {
    echo $(curl -s -X $1 "$API_BASE_URI/$2" \
        -H "X-Auth-Email: $CF_EMAIL" \
        -H "X-Auth-Key: $CF_TOKEN" \
        -H "Content-Type: application/json" \
        --data "${4:-''}" ) | jq -r $3
}

# get the zone id for the requested zone
ZONE_ID=$(api_call "GET" "zones?name=$ZONE_NAME&status=active" '.result[0].id')

# Get the A record id
A_ID=$(api_call "GET" "zones/$ZONE_ID/dns_records?name=$ZONE_NAME&type=A" '.result[0].id')

# Update record
RES=$(api_call "PATCH" "zones/$ZONE_ID/dns_records/$A_ID" ".success" "{\"content\": \"$CURR_IP\"}")

if [[ $RES ]]; then
    echo $CURR_IP > $IP_FILE
    MSG="DDNS New IP $CURR_IP"
    echo $MSG
    logger $MSG
    exit 0
fi

exit 1
