#!/bin/bash

source settings

date_forecast=$1

if [[ -z $date_forecast ]];then
  date_forecast=`date +%Y%m%d`
  echo " date_forecast not provided, starting with $date_forecast"
fi

logdir=$dir_log/$date_forecast

mkdir -p $logdir
mkdir -p $dir_tmp

run_hours=$forecast_length
ts_buffer=`echo "scale=0; 6 * 3600 / $wrf_timestep"|bc` # every 6 hours dumps time series buffer into file
frames_wrfout=`echo "scale=0; $run_hours +1"|bc`

end_date=`date -d "$date_forecast +$run_hours hours" +%Y%m%d`


#format initial and end dated for wrf WRF namelist
yyyy1=`echo $date_forecast |cut -c 1-4`
mm1=`echo $date_forecast |cut -c 5-6`
dd1=`echo $date_forecast |cut -c 7-8`
hh1=$start_hour_forecast

yyyy2=`echo $end_date |cut -c 1-4`
mm2=`echo $end_date |cut -c 5-6`
dd2=`echo $end_date |cut -c 7-8`
hh2=`date -d "$date_forecast + $run_hours hour" +%H`


# copy necessary files into work directory
cp $dir_namelist/namelist.input.tpl $dir_tmp

cd $dir_tmp

ln -sf $dir_exe/real.exe .


ln -sf $dir_geogrid_files/* .

#build the namelist.input for real.exe, from template:
cat namelist.input.tpl | \
sed "s/@@ts_buf_size@@/${ts_buffer}/g" | \
sed "s/@@wrf_timestep@@/${wrf_timestep}/g" | \
sed "s/@@adaptive_timestep@@/${adaptive_timestep}/g" | \
sed "s/@@frames_wrfout@@/${frames_wrfout}/g" | \
sed "s/yyyy1/${yyyy1}/g" | \
sed "s/mm1/${mm1}/g" | \
sed "s/dd1/${dd1}/g" | \
sed "s/hh1/${hh1}/g" | \
sed "s/yyyy2/${yyyy2}/g" | \
sed "s/mm2/${mm2}/g" | \
sed "s/dd2/${dd2}/g" | \
sed "s/hh2/${hh2}/g" >  namelist.input


#launch
./real.exe #&> $logdir/log_04_real_${date_forecast}.log

