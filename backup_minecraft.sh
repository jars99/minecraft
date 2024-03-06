#!/bin/bash
SERVER=nas
CLIENT=minecraft
BACKUP_DIR=/mnt/new_8tb/Backup/Minecraft
LOCAL_PATH=/home/jars99/minecraft

TS=$(date +%F_%k%M)
DEST=$BACKUP_DIR/$TS
echo "Getting Current Backup location"
CURRENT=$(ssh $SERVER readlink -f $BACKUP_DIR/latest)
echo "  Current Destination: $SERVER:$CURRENT"
echo "Creating Destination Directory: $SERVER:$DEST"
ssh $SERVER mkdir $DEST
echo "Rsync command: ssh $SERVER rsync -av --link-dest=$CURRENT $CLIENT:$LOCAL_PATH $DEST"
ssh $SERVER rsync -av --link-dest=$CURRENT $CLIENT:$LOCAL_PATH $DEST
echo "Removing the latest link"
ssh $SERVER rm $BACKUP_DIR/latest
echo "Creating the new latest link" 
ssh $SERVER "cd $BACKUP_DIR && ln -s $TS latest"
