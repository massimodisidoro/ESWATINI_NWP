#!/bin/bash
# script preparing file for wrf preprocessor.
# essentially launches the ungrib tool
set -x

source settings


date_forecast=$1

if [[ -z $date_forecast ]];then
  date_forecast=`date +%Y%m%d`
  echo " date_forecast not provided, starting with $date_forecast"
fi



date_gfs=`date -d "$date_forecast " +%Y%m%d`


run_hours=$(( ndays*24 ))
end_date=`date -d "$date_forecast +$run_hours hours" +%Y%m%d`

start_hour=$start_hour_forecast
end_hour=$end_hour_forecast

#formate dates for wrf WPS namelist
yyyy=`echo $date_forecast |cut -c 1-4`
mm=`echo $date_forecast |cut -c 5-6`
dd=`echo $date_forecast |cut -c 7-8`
new_fmt_start_date="${yyyy}-${mm}-${dd}"

yyyy=`echo $end_date |cut -c 1-4`
mm=`echo $end_date |cut -c 5-6`
dd=`echo $end_date |cut -c 7-8`
new_fmt_end_date="${yyyy}-${mm}-${dd}"


mkdir -p $dir_log
mkdir -p $dir_tmp
dir_grib=${dir_input_meteo}/${date_gfs}_${gfs_reference_time}/

cp $dir_exe/link_grib.csh $dir_tmp
cp $dir_namelist/namelist.wps.tpl $dir_tmp
cp $dir_namelist/Vtable.GFS $dir_tmp/Vtable
cp $dir_exe/ungrib.exe $dir_tmp

cd $dir_tmp


cat namelist.wps.tpl |
sed "s/@@start_date@@/${new_fmt_start_date}/g" | \
sed "s/@@start_hour@@/${start_hour}/g" | \
sed "s/@@end_date@@/${new_fmt_end_date}/g" | \
sed "s/@@end_hour@@/${end_hour}/g"  > namelist.wps


#cleaning
#rm -f GRIBFILE.*
#date=$new_fmt_date_forecast
#while [[ $date != $new_fmt_end_date ]];do
#rm -f FILE*{$date}*
#date=`date -d "$date + 1 day" +%Y-%m-%d`
#done

datesst=`date -d "$date_gfs -1 day" +%Y%m%d`
ln -fs $dir_input_sst/${datesst}/* $dir_grib/

./link_grib.csh $dir_grib/


./ungrib.exe  &> $dir_log/log_02_ungrib_${date_forecast}-${end_date}.log
