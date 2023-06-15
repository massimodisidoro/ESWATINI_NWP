#!/usr/bin/bash

gfs_reference_time=$1

if [[ $# -ne 1 ]];then
  echo " gfs_reference_time in the format hh (e.g. 00, 12, ) "
  echo "STOP"
  exit
fi

source settings
days=$clear_older_days


echo "Start cleaning folders and files older than $days days in:
$dir_archive"

echo "" 

find $dir_archive/* -type d -mtime +$days -print
find $dir_archive/* -type d -mtime +$days -exec rm -r {} \; &>/dev/null

find $dir_archive/clearing -name "clear*" -type f -mtime +$days -print
find $dir_archive/clearing -name "clear*" -type f -mtime +$days -exec rm  {} \; &>/dev/null

echo "" 
echo "End cleaning folders and files older than $days days in $dir_archive"
echo "" 

