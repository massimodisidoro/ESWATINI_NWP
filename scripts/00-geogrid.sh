#!/bin/bash
# this script creates geo_em files for wrf. It must be launched once
# and for all, unless domains are changed.


#set -x
source settings

date_forecast=$1

if [[ -z $date_forecast ]];then
  echo "provide date_forecast (yyyymmdd)"
  exit
fi

#run_hours=$(( ndays*24 ))
run_hours=$forecast_length
end_date=`date -d "$date_forecast +$run_hours hours" +%Y%m%d`

start_hour=$start_hour_forecast
end_hour=$end_hour_forecast


yyyy=`echo $date_forecast |cut -c 1-4`
mm=`echo $date_forecast |cut -c 5-6`
dd=`echo $date_forecast |cut -c 7-8`
new_fmt_start_date="${yyyy}-${mm}-${dd}"

yyyy=`echo $end_date |cut -c 1-4`
mm=`echo $end_date |cut -c 5-6`
dd=`echo $end_date |cut -c 7-8`
new_fmt_end_date="${yyyy}-${mm}-${dd}"

log_dir="$dir_log/geogrid/$date_forecast/"
mkdir -p $log_dir/
mkdir -p $dir_tmp


cp  $dir_namelist/namelist.wps.tpl $dir_tmp/namelist.wps.tpl

cp $dir_exe/geogrid.exe $dir_tmp
cp $dir_namelist/GEOGRID.TBL.ARW $dir_tmp/GEOGRID.TBL

cd $dir_tmp

geogrid_output=$dir_input/geogrid_files
geogrid_table_path=$dir_tmp

mkdir -p $geogrid_output

cat namelist.wps.tpl | \
sed "s/@@start_date@@/${new_fmt_start_date}/g" | \
sed "s/@@start_hour@@/${start_hour}/g" | \
sed "s/@@end_date@@/${new_fmt_end_date}/g" | \
sed "s/@@end_hour@@/${end_hour}/g" | \
sed "s!@@geogrid_output@@!$geogrid_output!g" | \
sed "s!@@geogrid_table_path@@!$geogrid_table_path!g" | \
sed "s!@@geo_data@@!$dir_wrf_static_data!g" > namelist.wps

#export OMP_NUM_THREADS=1
#bsub  -q $coda_geogrid -n $nproc_geogrid -We 30 -e $log_dir/geogrid_${start_date}.err -o $log_dir/geogrid_${start_date}.out ./script_lancia_geogrid.sh

./geogrid.exe &> $log_dir/geogrid.log
