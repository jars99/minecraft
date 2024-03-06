#!/bin/bash
. serverlist.sh
NAME=$1
PORT=$(cat next_port)
MC_DIR=/home/jars99/minecraft
DEFAULT_SERVER=jars99
USER=jars99
LOCAL_IP="192.168.0.8"
TYPE="$2"
if [ "$NAME" == "" ] || [ "$TYPE" == "" ];then
  echo "usage: $0 NAME -r|-s|url [version]"
  exit 1
fi

DATA_URL=https://launchermeta.mojang.com/mc/game/version_manifest.json
echo "Downloading latest data"|tee -a $LOG
MANIFEST=$(curl -s $DATA_URL)
if [ "$TYPE" == "-r" ];then
  RELEASE=$(echo "$MANIFEST"|jq -r '.latest.release')
  echo "Latest Release: $RELEASE"|tee -a $LOG
  VERSION=$RELEASE
  RELEASE_URL=$(echo "$MANIFEST"|jq -r '.versions[]|select(.id=="'$RELEASE'").url')
  RELEASE_DATA=$(curl -s $RELEASE_URL)
  URL=$(echo "$RELEASE_DATA"|jq -r '.downloads.server.url')
  SERVERLIST=RELEASE
elif [ "$TYPE" == -s ];then
  SNAPSHOT=$(echo "$MANIFEST"|jq -r '.latest.snapshot')
  VERSION=$SNAPSHOT
  echo "Latest Snapshot: $SNAPSHOT"|tee -a $LOG
  SNAPSHOT_URL=$(echo "$MANIFEST"|jq -r '.versions[]|select(.id=="'$SNAPSHOT'").url')
  SNAPSHOT_DATA=$(curl -s $SNAPSHOT_URL)
  URL=$(echo "$SNAPSHOT_DATA"|jq -r '.downloads.server.url')
  SERVERLIST=SNAPSHOT
else
  if [ "$3" == "" ];then
    echo "When passing in a URL, you must follow it with a version number"
    exit 1
  fi
  URL=$TYPE
  VERSION=$3
  SERVERLIST=OTHER
fi

echo "Using URL: $URL"
echo "Using Version: $VERSION"
mkdir $NAME
cp $MC_DIR/$DEFAULT_SERVER/server.properties $NAME/
cp $MC_DIR/$DEFAULT_SERVER/eula.txt $NAME/
sed -i "s/$DEFAULT_SERVER/$NAME/" $MC_DIR/$NAME/server.properties
sed -i "s/25008/$PORT/" $MC_DIR/$NAME/server.properties
sed -i "s/${SERVERLIST}_SERVERS=\"/${SERVERLIST}_SERVERS=\"$NAME /" $MC_DIR/serverlist.sh
wget $URL -O $MC_DIR/$NAME/server-${VERSION}.jar
cd $NAME
ln -s server-${VERSION}.jar $NAME.jar
cd ..
NEXT_PORT=$(echo "$PORT + 1"|bc)
echo "$NEXT_PORT" > next_port
echo "Nearly Done:"
#echo -e "Run this:\nsudo echo \"  sudo -H -u $USER $MC_DIR/screen.sh $NAME\" > /etc/rc.local"
echo -e "Start the server with this: \n  $MC_DIR/screen.sh $NAME"
echo -e "\n Server Info: $LOCAL_IP:$PORT"
