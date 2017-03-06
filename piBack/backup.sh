#!/bin/bash
#
# backup.sh
#
# By Matt Agresta
# 01/28/2017
# Copies files from raspberry pi to local disk 
# 
# Variables

while getopts ":s:h" opt; do
  case $opt in
    s)
      HOST=$OPTARG
      ;;
    h)
      echo "Usage....."
      echo "  Options:"
      echo "      -s: Required, Server name"
      echo "      -d: Required, Destination Folder"
      exit 0
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument. Use -h for more information." >&2
      exit 1
      ;;
  esac
done

#Variables
IMGFILE=$BCKUPDIR/$HOST.img

#Mount Image File
LOOP=$($APPDIR/makeloop.sh -i $IMGFILE)

#Look partitions in config file
awk -F':' '{print $1" "$2" "$3" "$4}' $CONFIGDIR/$HOST.config | while read LPART BLOCKDEV TARGET UUID
do
   DEST=/mnt/$HOST.img-$LPART
   echo "Backing up $HOST:$TARGET to $DEST"
   rdiff-backup --create-full-path --force --exclude-globbing-filelist $CONFIGDIR/$HOST.$LPART.exclude root@$HOST::$TARGET $DEST

done

#Close Loop
$APPDIR/rmloop.sh -d $LOOP
