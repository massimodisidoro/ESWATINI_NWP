#!/bin/bash
set -x
source settings

date_forecast=$1
gfs_reference_time=$2

if [[ $# -ne 2 ]];then
  echo " Please provide in argument:"
  echo " date_forecast in the format yyyymmdd"
  echo " gfs_reference_time in the format hh (e.g. 00, 12, ) "
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


logdir=$dir_log/$date_forecast

mkdir -p $logdir
mkdir -p $dir_tmp

year=`date -d "$date_forecast" +%Y`
month=`date -d "$date_forecast" +%m`
day=`date -d "$date_forecast" +%d`
hour=$gfs_reference_time

filewrf="$dir_tmp/wrfout_d02_${year}-${month}-${day}_${hour}:00:00"

end_step=$(( forecast_length -1))


fig_meteo_archive=$dir_archive/${date_forecast}_${gfs_reference_time}/figures/
mkdir -p $fig_meteo_archive

#skewt plots
tmpfile=$dir_tmp/tmpfile
cat $dir_post/tslist | grep -v "#" > $tmpfile
while read name prefix lat lon;do
  name=`echo $name |sed "s/_/ /g"`
  $python $dir_post/plot_skewt.py $filewrf --start 3 --end $end_step --deltastep $deltastep_maps --lat $lat --lon $lon --profilename "$name" --out $fig_meteo_archive
done < $tmpfile
rm $tmpfile
#set -x
#meteograms
Rscript $dir_post/meteogram.R --pathin $dir_tmp --date_forecast ${date_forecast}${gfs_reference_time} --out $fig_meteo_archive


#maps
$python $dir_post/plot_figures.py $filewrf --start 3 --end $end_step --out $fig_meteo_archive --config $dir_post/var.yaml --deltastep $deltastep_maps
