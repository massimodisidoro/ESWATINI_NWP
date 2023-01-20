#!/bin/bash
# script preparing file for wrf preprocessor.
# essentially launches the ungrib tool

source settings

date_forecast=$1
gfs_reference_time=$2

if [[ $# -ne 2 ]];then
  echo " Please provide in argument:"
  echo " date_forecast in the format yyyymmdd"
  echo " gfs_reference_time in the format hh (e.g. 00, 12, ) "
  echo " Example:   $0 20230119 12"
  echo "STOP"
  exit
fi

if [[ -z $date_forecast ]];then
  date_forecast=`date +%Y%m%d`
  echo " date_forecast not provided, starting with $date_forecast"
fi
if [[ -z $gfs_reference_time ]];then
        echo "provide GFS run reference time (00, 12)"
  exit
fi


dir_tmp="$dir_root/scratch_${gfs_reference_time}UTC"
dir_log="$dir_tmp/log"
dir_metgrid_files="$dir_tmp"
mkdir -p $dir_tmp $dir_log $dir_metgrid_files



date_gfs=`date -d "$date_forecast " +%Y%m%d`


run_hours=$forecast_length
end_date=`date -d "$date_forecast +$run_hours hours" +%Y%m%d`


start_hour=$gfs_reference_time
end_hour=`date -d "$date_forecast + $run_hours hour" +%H`

#formate dates for wrf WPS namelist
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

datesst=`date -d "$date_gfs -1 day" +%Y%m%d`
ln -fs $dir_input_sst/${datesst}/* $dir_grib/

./link_grib.csh $dir_grib/


./ungrib.exe  &> $logdir/log_02_ungrib_${date_forecast}-${end_date}.log
