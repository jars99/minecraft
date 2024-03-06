#!/bin/bash
. serverlist.sh
. dns_info.sh
OUT_FILE=public_servers.json
OUTPUT="{ \"data\": ["
for SERVER in $RELEASE_SERVERS;do
	if [ "${SERVER_DOMAINS["$SERVER"]}" != "" ];then
		DOMAIN=${SERVER_DOMAINS["$SERVER"]}
  	PORT=${SERVER_PORTS["$SERVER"]}
	  OUTPUT+="\n{\"{#SERVER}\": \"$SERVER\", \"{#DOMAIN}\": \"$DOMAIN\", \"{#PORT}\": \"$PORT\"},"
  fi
done
OUTPUT="${OUTPUT::-1}]\n}"
echo -e "$OUTPUT" > $OUT_FILE

