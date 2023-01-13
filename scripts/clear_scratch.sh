#!/usr/bin/bash
#set -x
source settings


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

