#!/usr/bin/bash
#set -x
source settings
gfs_reference_time=$1

if [[ $# -ne 1 ]];then
  echo " Please provide in argument:"
  echo " gfs_reference_time in the format hh (e.g. 00, 12, ) "
  echo "STOP"
  exit
fi



dir_tmp="$dir_root/scratch_${gfs_reference_time}UTC"


echo "Start cleaning scratch dir $dir_tmp"

echo "" 

echo "rm  $dir_tmp/*"
rm  $dir_tmp/*
echo "cleaning completed"
