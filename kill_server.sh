#!/bin/bash
SERVER=$1
USER=jars99
if [ "$SERVER" == "" ];then
  echo "Pass in the server name"
  exit 1
else
  if [ "$1" == "all" ];then
    echo "Killing all servers"
    . serverlist.sh
    for SERVER in $RELEASE_SERVERS $SNAPSHOT_SERVERS $OTHER_SERVERS; do
      echo "Killing server: $SERVER"
      PID=$( ps aux|grep $USER|grep java|grep $SERVER.jar|awk '{print $2}')
      if [ "$PID" == "" ];then
        echo "no PID found"
      else
        echo "Killing java process: $PID"
        kill -9 $PID
      fi
    done
  else
    echo "Killing server: $1"
    PID=$( ps aux|grep $USER|grep java|grep $1.jar|awk '{print $2}')
    if [ "$PID" == "" ];then
      echo "no PID found"
    else
      echo "Killing java process: $PID"
      kill -9 $PID
    fi
  fi
fi
