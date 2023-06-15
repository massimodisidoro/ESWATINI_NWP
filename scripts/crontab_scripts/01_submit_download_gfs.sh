#!/usr/bin/bash

#set -x
source /storage/forecast_system/ESWATINI_NWP/scripts/settings

date_forecast=`date +%Y%m%d`
#trick to choose between gfs_reference_time 00 and 12
# comparing the current hour: if local time is > 0 and < 12 then set to 00
# otherwise set to 12
hour=`date  +%H`
if [[ ${hour#0} -ge "00" ]];then 
  export time=00
fi
if [[ ${hour#0} -ge "12" ]];then
  export time=12
fi
gfs_reference_time=$time

dir_tmp="$dir_root/scratch_${gfs_reference_time}UTC"
dir_log="$dir_archive/${date_forecast}_${gfs_reference_time}/log"
mkdir -p $dir_log $dir_scratch



cd $dir_script 

$dir_script/01-download_gfs.sh $date_forecast $gfs_reference_time &> $dir_log/log_01-download_gfs_${date_forecast}.log
