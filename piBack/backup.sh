#!/bin/bash
#
# backup.sh
#
# By Matt Agresta
# 01/28/2017
# Copies files from raspberry pi to local disk 
# 
# Variables
bkupdir=/backup

while getopts ":s:h" opt; do
  case $opt in
    s)
      srvname=$OPTARG
      ;;
    h)
      echo "Usage....."
      echo "  Options:"
      echo "      -s: Required, Server name"
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

#Create directory for server
mkdir $bkupdir/$srvname

#Run Backup 
for dir in `ssh $srvname -q "ls /"`
/usr/bin/rdiff-backup --exclude-globbing-filelist /data/piBack/config/backup.exclude $srvname:/ $bkupdir/$srvname
