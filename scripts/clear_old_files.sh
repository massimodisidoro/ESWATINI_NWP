#!/usr/bin/bash

source settings
days=5


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

