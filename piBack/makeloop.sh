#!/bin/bash
# Matt Agresta
# 01/28/2016
# Take img file and creates loopback devices

while getopts ":i:h" opt; do
  case $opt in
    i)
      img_file=$OPTARG
      ;;
    h)
      echo "Usage....."
      echo "  Options:"
      echo "      -i: Required, path to image file"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
    :)
      echo "Option -$OPTARG requires an argument. Use -h for more information." >&2
      exit 1
      ;;
  esac
done


#Create loopback device to attach file to
modprobe loop
loop_dev=$(losetup -f)

#Attach image file to loopback device
losetup $loop_dev $img_file

#Scan partitions
partprobe $loop_dev

#Look for partitions
for part in `ls $loop_dev*`
do
     item=$(echo $part | awk -F\/ '{print $3}')
     img_name=$(echo $img_file | awk -F\/ '{print $NF}')
     if [[ "$item" == "loop0" ]];
     then
          continue
     fi
     mkdir /mnt/$img_name-$item
     mount $part /mnt/$img_name-$item
     echo "/mnt/${img_name}-${item} Created." 
done
