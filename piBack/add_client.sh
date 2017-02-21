#!/bin/bash
#
# add_client.sh
#
# By Matt Agresta
# 02/20/2017
# Create Client Config 
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


#Creat config file
CONFIGFILE=$CONFIGDIR/$HOST.config
touch $CONFIGFILE
cat /dev/null > $CONFIGFILE

#Mount Image
LOOP=$($APPDIR/makeloop.sh -i $BCKUPDIR/$HOST.img)

for PART in `fdisk -l /dev/$LOOP | grep -e ^/dev | awk '{print $1}'`
do
   #Get Loops name
   PARTNAME=$(echo $PART | awk -F\/ '{print $NF}')
   #Get UUID of loop partitions
   LUUID=$(blkid -s UUID -o value $PART) 
   BLOCKDEV=$(ssh -q piback@$HOST "sudo blkid -U $LUUID")
   TARGET=$(ssh -q piback@$HOST "sudo mount" | grep -e ^$BLOCKDEV | awk '{print $3}')

   #Write Config info to file
   echo "$PART:$BLOCKDEV:$TARGET:$LUUID" >> $CONFIGFILE

   #Create partition exclude lists
   touch $CONFIGDIR/$HOST.$PARTNAME.exclude
   #cat /dev/null > $CONFIGDIR/$HOST.$PARTNAME.exclude

   #If Root partition add boot to file
   #Eventually will look for target parent in targets list and add to relative exclusion list
   if [[ $TARGET == "/" ]]
   then
     echo "/boot" >> $CONFIGDIR/$HOST.$PARTNAME.exclude
   fi
   
   #Coming Soon....
   #Detect NFS Mounts under TARGET and add to exclusion

done

#Unmount image
$APPDIR/rmloop.sh -d $LOOP   
