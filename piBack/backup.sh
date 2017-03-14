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


#Look partitions in config file
awk -F':' '{print $1" "$2" "$3" "$4}' $CONFIGDIR/$HOST.config | while read TYPE NAME NUM TARGET 
do
   if [[ $TYPE =~ ^PART ]]
   then
      #Set up destination
      DEST=$BCKUPDIR/$HOST/$NAME$NUM
      mkdir -p $DEST
      #Exclusion file for partition
      XFILE=/$CONFIGDIR/$HOST.$NAME$NUM.exclude
      
      echo "Backing up $HOST:$TARGET to $DEST"
      rdiff-backup --create-full-path --force --exclude-globbing-filelist $XFILE root@$HOST::$TARGET $DEST
   fi
done

