#!/usr/bin/bash

source settings
days=5
gfs_reference_time=$1

if [[ $# -ne 1 ]];then
  echo " gfs_reference_time in the format hh (e.g. 00, 12, ) "
  echo "STOP"
  exit
fi


dir_tmp="$dir_root/scratch_${gfs_reference_time}UTC"
dir_log="$dir_tmp/log"
dir_metgrid_files="$dir_tmp"
mkdir -p $dir_tmp $dir_log $dir_metgrid_files




echo "Start cleaning files older than $days days in:
$dir_tmp"

echo "" 

find $dir_tmp -type f -mtime +$days -print
find $dir_tmp -type f -mtime +$days -exec rm {} \; &>/dev/null

find $dir_log/*/* -type f -mtime +$days -print
find $dir_log/*/* -type f -mtime +$days -exec rm -r  {} \; &>/dev/null

find $dir_input/ncep -type f -mtime +$days -print
find $dir_input/ncep -type f -mtime +$days -exec rm -r  {} \; &>/dev/null

find $dir_input/sst -type f -mtime +$days -print
find $dir_input/sst -type f -mtime +$days -exec rm -r  {} \; &>/dev/null
echo "" 
echo "End clean files older than $days days"
echo "" 

