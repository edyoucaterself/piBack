#!/bin/bash
#
# add_img.sh
#
# By Matt Agresta
# 02/11/2017
# Create base image from sd card 
# Create config for image 
# Variables
BKUPDIR=/backup
IMAGES=$BKUPDIR/images
CONFIG=/data/piBack/config

while getopts ":s:d:h" opt; do
  case $opt in
    s)
      HOST=$OPTARG
      ;;
    d)
      DEVICE=$OPTARG
      ;;
    h)
      echo "Usage....."
      echo "  Options:"
      echo "      -s: Required, Server name"
      echo "      -d: Required, Source name"
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

#Create Image
dd bs=4096 if=$DEVICE of=$IMAGES/$HOST.img
