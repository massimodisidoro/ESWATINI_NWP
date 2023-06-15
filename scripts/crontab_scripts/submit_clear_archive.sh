#!/usr/bin/bash
source /home/enwp/.bashrc
source /storage/forecast_system/ESWATINI_NWP/scripts/settings

date_forecast=`date +%Y%m%d`
#trick to choose between gfs_reference_time 00 and 12
# comparing the current hour: ig it is > 0 and < 12 then set to 00
# otherwise set to 12
hour=`date  +%H`
if [[ ${hour#0} -ge "00" ]];then
  export time=00
fi
if [[ ${hour#0} -ge "12" ]];then
  export time=12
fi
gfs_reference_time=$time

mkdir -p $dir_archive/clearing


cd $dir_script  

$dir_script/clear_archive.sh $gfs_reference_time > $dir_archive/clearing/clear_archive_$date_forecast
