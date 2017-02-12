#!/bin/bash
#
# backup.sh
#
# By Matt Agresta
# 01/28/2017
# Copies files from raspberry pi to local disk 
# 
# Variables
BKUPDIR=/backup
$CONFIG=/data/piBack/config

while getopts ":s:h" opt; do
  case $opt in
    s)
      HOST=$OPTARG
      ;;
    d)
      DEST=$OPTARG
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


#Run Backup 
/usr/bin/rdiff-backup --exclude-globbing-filelist $CONFIG/$HOST.filelist $HOST::/ $BKUPDIR/$HOST
