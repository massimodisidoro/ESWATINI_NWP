#!/usr/bin/bash

source settings
ndays=5


echo "Start cleanind files older than $ndays days in:
$dir_tmp"

echo "" 

find $dir_tmp -type f -mtime +$ndays -print
find $dir_tmp -type f -mtime +$ndays -exec rm {} \; &>/dev/null

find $dir_log/* -type f -mtime +$ndays -print
find $dir_log/* -type f -mtime +$ndays -exec rm -r  {} \; &>/dev/null

find $dir_input/ncep -type f -mtime +$ndays -print
find $dir_input/ncep -type f -mtime +$ndays -exec rm -r  {} \; &>/dev/null

find $dir_input/sst -type f -mtime +$ndays -print
find $dir_input/sst -type f -mtime +$ndays -exec rm -r  {} \; &>/dev/null
echo "" 
echo "End clean files older than $ndays days"
echo "" 

