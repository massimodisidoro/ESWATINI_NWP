#!/bin/bash
#prepares horizontally interpolated (from GFS to wrf grid) meteo files.
# the vertical interpolation (from GFS to WRF levels) is performed
# by the real.exe tool in next step (04-real.sh).


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

dir_tmp="$dir_root/scratch_${gfs_reference_time}UTC"
dir_log="$dir_tmp/log"
dir_metgrid_files="$dir_tmp"
mkdir -p $dir_tmp $dir_log $dir_metgrid_files




run_hours=$forecast_length
end_date=`date -d "$date_forecast +$run_hours hours" +%Y%m%d`

start_hour=$gfs_reference_time
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

#cleaning  old stuff from previous run
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
export OMP_NUM_THREADS=$omp_wps_threads
./metgrid.exe &> $logdir/log_03_metgrid_${date_forecast}.log
