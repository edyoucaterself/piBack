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

declare -a CONFIGLIST

#Connect to host and gather info
CFGINFO=$(ssh $HOST /bin/bash <<'EOSSH'

   #Search for block devices
   lsblk -nbo TYPE,NAME,MOUNTPOINT,SIZE | while read DEVTYPE DEVNAME TARGET SIZEKB
   do
      #Get Disk Info
      if [[ $DEVTYPE == "disk" ]]     
      then
         #Values shift with only 3 columns
         SIZEKB=$TARGET
         BLOCKSIZE=$(sudo blockdev --getbsz /dev/$DEVNAME)
         echo "DISK:$DEVNAME:$SIZEKB:$BLOCKSIZE"
      fi
      #Get Part info
      if [[ $DEVTYPE == "part" ]]     
      then
         #Need TYPE:PARTNAME:PARTNUM:TARGET 
         PART=$(echo $DEVNAME | tr -cd '[[:alnum:]]._-')
         [[ $PART =~ (.*)(p[0-9]*) ]]
         DEVNAME=${BASH_REMATCH[1]}
         PARTNUM=${BASH_REMATCH[2]} 
         

         if [[ $TARGET == "/" ]]
         then
            declare -a EXCLUDELIST
            #tmpfs to add
            declare -a MOUNTLIST=($(df -a | awk '{print $6}' | sed "1 d"))
            #Search through list for dummy files
            for x in ${MOUNTLIST[@]}
            do
               if [[ $x != $TARGET ]] 
               then
                  echo "Inner$x"
                  EXCLUDELIST=(${EXCLUDELIST[@]} $x)
               fi
           done
         fi
         echo "PART:$DEVNAME:$PARTNUM:$TARGET" 
         echo "${EXCLUDELIST[@]}"

      fi
   done

EOSSH
)

#Loop through CFGINFO and write config files
for i in `echo $CFGINFO`
do
   if [[ $i =~ ^DISK.* ]]
   then
      echo "$i" >> $CONFIGFILE
   elif [[ $i =~ ^PART:(.*):(.*):(.*) ]]
   then
      #Capture PARTName for config file name
      DEVNAME=${BASH_REMATCH[1]}
      PARTNUM=${BASH_REMATCH[2]} 
      echo "$i" >> $CONFIGFILE
      PARTCFG=$CONFIGDIR/$HOST.$DEVNAME$PARTNUM.exclude
      #Clean File
      touch $PARTCFG
      cat /dev/null > $PARTCFG
   elif [[ $i =~ ^\/.* ]]
   then
      echo "$i" >> $PARTCFG
   fi
done

