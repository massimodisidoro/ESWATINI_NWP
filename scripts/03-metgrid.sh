#!/bin/bash
#prepares horizontally interpolated (from GFS to wrf grid) meteo files.
# the vertival interpolation (from GFS to WRF levels) is performed
# by the real.exe tool, next step.

#set -x

source settings

date_forecast=$1

if [[ -z $date_forecast ]];then
  date_forecast=`date +%Y%m%d`
  echo " date_forecast not provided, starting with $date_forecast"
fi


run_hours=$forecast_length
end_date=`date -d "$date_forecast +$run_hours hours" +%Y%m%d`

start_hour=$start_hour_forecast
end_hour=`date -d "$date_forecast + $run_hours hour" +%H`

#format initial and end dates for wrf WPS namelist
yyyy=`echo $date_forecast |cut -c 1-4`
mm=`echo $date_forecast |cut -c 5-6`
dd=`echo $date_forecast |cut -c 7-8`
new_fmt_start_date="${yyyy}-${mm}-${dd}"

yyyy=`echo $end_date |cut -c 1-4`
mm=`echo $end_date |cut -c 5-6`
dd=`echo $end_date |cut -c 7-8`
new_fmt_end_date="${yyyy}-${mm}-${dd}"


logdir=$dir_log/$date_forecast
mkdir -p $logdir
mkdir -p $dir_tmp

#copy necessary files into working dir
cp $dir_namelist/namelist.wps.tpl $dir_tmp
cp $dir_namelist/METGRID.TBL.ARW $dir_tmp/METGRID.TBL
cp $dir_exe/metgrid.exe $dir_tmp

cd $dir_tmp


metgrid_table_path=$dir_tmp
mkdir -p $dir_metgrid_files
#cleaning 
rm -f $dir_metgrid_files/met_em*.nc

# build namelist.wps from template
cat namelist.wps.tpl | \
sed "s/@@start_date@@/${new_fmt_start_date}/g" | \
sed "s/@@start_hour@@/${start_hour}/g" | \
sed "s/@@end_date@@/${new_fmt_end_date}/g" | \
sed "s/@@end_hour@@/${end_hour}/g" | \
sed "s!@@geogrid_output@@!${dir_geogrid_files}!g" | \
sed "s!@@metgrid_table_path@@!$metgrid_table_path!g" | \
sed "s!@@metgrid_output@@!$dir_metgrid_files!g" > namelist.wps

#launch executable
./metgrid.exe #&> $logdir/log_03_metgrid_${date_forecast}.log
