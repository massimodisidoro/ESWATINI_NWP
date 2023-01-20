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
dir_log="$dir_tmp/log"
dir_metgrid_files="$dir_tmp"
mkdir -p $dir_tmp $dir_log $dir_metgrid_files


echo "Start cleaning unnecessary files from "
echo "$dir_tmp "

echo "" 

echo "rm  $dir_tmp/GRIB*"
echo "rm  $dir_tmp/FILE*"
echo "rm  $dir_tmp/met_em*"
echo "rm  $dir_tmp/wrfinput*"
echo "rm  $dir_tmp/wrfbdy*"

rm  $dir_tmp/GRIB*
rm  $dir_tmp/FILE*
rm  $dir_tmp/met_em*
rm  $dir_tmp/wrfinput*
rm  $dir_tmp/wrfbdy*

