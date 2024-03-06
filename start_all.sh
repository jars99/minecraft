#!/bin/bash
MC_DIR=/home/jars99/minecraft
cd $MC_DIR
. serverlist.sh
for SERVER in $RELEASE_SERVERS $SNAPSHOT_SERVERS $OTHER_SERVERS; do
  echo "Server: $SERVER"
  ./screen.sh $SERVER
done
