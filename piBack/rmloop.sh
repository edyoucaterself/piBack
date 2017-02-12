#!/bin/bash
# Matt Agresta
# 01/28/2016
# Unmount and delete loopback devices

while getopts ":d:h" opt; do
  case $opt in
    d)
      loop_dev=$OPTARG
      ;;
    h)
      echo "Usage....."
      echo "  Options:"
      echo "      -l: Required, path to loopback device"
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

echo "Cleaning up ${loop_dev}"

#Grab loop name
loop_name=$(echo $loop_dev | awk -F\/ '{print $3}')
#Look for partitions
for part in `ls -d /mnt/*$loop_name*/`
do
     echo "Unmounting ${part}"
     mnt_chk=$(umount $part)
     #Check if mounted still, if so skip rm -rf and set flag
     if [[ $? -ne 0 ]];
     then
         continue
     fi 
     rm -rf $part
done

#Destroy Loopback
losetup -d /dev/$loop_dev
