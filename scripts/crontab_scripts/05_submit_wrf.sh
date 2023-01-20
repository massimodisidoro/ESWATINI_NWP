#!/usr/bin/bash
source /home/enwp/.bashrc
source /home/enwp/forecast_system/ESWATINI_NWP/scripts/settings

date_forecast=`date +%Y%m%d`
#trick to choose between gfs_reference_time 00 and 12
# comparing the current hour: ig it is > 0 and < 12 then set to 00
# otherwise set to 12
hour=`date -u +%H`
if [[ ${hour#0} -ge "00" ]];then
  export time=00
fi
if [[ ${hour#0} -ge "12" ]];then
  export time=12
fi
gfs_reference_time=$time

dir_tmp="$dir_root/scratch_${gfs_reference_time}UTC"
dir_log="$dir_tmp/log"

logdir=$dir_log/$data
mkdir -p $logdir

cd $dir_script  

$dir_script/05-wrf.sh $date_forecast $gfs_reference_time
