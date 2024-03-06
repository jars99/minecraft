#!/bin/bash
MC_DIR=/home/jars99/minecraft

. $MC_DIR/serverlist.sh

LOG=/var/log/minecraft/upgrade_minecraft.log
DATE=$(date)
echo -e "\n$DATE" |tee -a $LOG
DATA_URL=https://launchermeta.mojang.com/mc/game/version_manifest.json
echo "Downloading latest data"|tee -a $LOG
MANIFEST=$(curl -s $DATA_URL)
RELEASE=$(echo "$MANIFEST"|jq -r '.latest.release')
SNAPSHOT=$(echo "$MANIFEST"|jq -r '.latest.snapshot')
echo "Latest Release: $RELEASE"|tee -a $LOG
RELEASE_URL=$(echo "$MANIFEST"|jq -r '.versions[]|select(.id=="'$RELEASE'").url')
RELEASE_DATA=$(curl -s $RELEASE_URL)
RELEASE_DOWNLOAD=$(echo "$RELEASE_DATA"|jq -r '.downloads.server.url')
echo "Latest Snapshot: $SNAPSHOT"|tee -a $LOG
SNAPSHOT_URL=$(echo "$MANIFEST"|jq -r '.versions[]|select(.id=="'$SNAPSHOT'").url')
SNAPSHOT_DATA=$(curl -s $SNAPSHOT_URL)
SNAPSHOT_DOWNLOAD=$(echo "$SNAPSHOT_DATA"|jq -r '.downloads.server.url')

if [ "$SNAPSHOT_DOWNLOAD" == "" ] || [ "$RELEASE_DOWNLOAD" == "" ];then
  echo "One of the download URLs is empty.  Exiting"|tee -a $LOG
  exit
fi

VERSIONS="RELEASE SNAPSHOT"

#URL=https://launcher.mojang.com/v1/objects/5998d2c7c15fea04b2541efdcbec4c8cfe5df2a6/server.jar
#if [ "$VERSION" == "" ] || [ "$URL" == "" ];then
#  echo "Update URL and VERSION VARIABLES first"
#  exit 1
#fi
for VERSION in $VERSIONS; do
  echo "Working through $VERSION"|tee -a $LOG
  eval NUMBER=\$${VERSION}
  echo "Version number: $NUMBER"|tee -a $LOG
  eval SERVERS=\$${VERSION}_SERVERS
  echo "list of $VERSION servers: $SERVERS"|tee -a $LOG
  eval URL=\$${VERSION}_DOWNLOAD
  echo "URL=$URL"|tee -a $LOG
  for i in $SERVERS; do
    echo "Checking existing if server $i is already running version $NUMBER"|tee -a $LOG
    CURRENT=$(readlink $MC_DIR/$i/$i.jar)
    CURRENT_VERSION=$(basename $CURRENT|awk -F- '{print $2}'|sed 's/.jar//')
    echo "Current Version: $CURRENT_VERSION"|tee -a $LOG
    if [ "$CURRENT_VERSION" == "$NUMBER" ];then
      echo "This version already installed for this server"|tee -a $LOG
      continue
    fi
    echo "Upgrading on server: $i"|tee -a $LOG
    PID=$( ps aux|grep java|grep $i.jar|awk '{print $2}')
    if [ "$PID" != "" ];then
      echo "Killing java process: $PID"|tee -a $LOG
      kill -9 $PID
    fi
    cd $MC_DIR/$i
    if ! [ -e "$MC_DIR/downloads/server-${NUMBER}.jar" ];then
      echo "Downloading version $NUMBER"|tee -a $LOG
      wget $URL -O $MC_DIR/downloads/server-${NUMBER}.jar
    fi
    cp $MC_DIR/downloads/server-${NUMBER}.jar .
    echo "Removing old symlink"|tee -a $LOG
    rm $i.jar
    echo "Creating new symlink"|tee -a $LOG
    ln -s server-${NUMBER}.jar $i.jar
    echo "Starting new process:"|tee -a $LOG
    $MC_DIR/screen.sh $i
    echo "Done with server $i"|tee -a $LOG
    sleep 2
  done
done

