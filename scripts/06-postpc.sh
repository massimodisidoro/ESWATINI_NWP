#!/bin/bash

source settings
#set -x

date_forecast=$1

if [[ -z $date_forecast ]];then
  date_forecast=`date +%Y%m%d`
  echo " date_forecast not provided, starting with today: $date_forecast"
fi

logdir=$dir_log/$date_forecast

mkdir -p $logdir
mkdir -p $dir_tmp

year=`date -d "$date_forecast" +%Y`
month=`date -d "$date_forecast" +%m`
day=`date -d "$date_forecast" +%d`
hour=`date -d "$date_forecast" +%H`

filewrf1="$dir_tmp/wrfout_d01_${year}-${month}-${day}_${hour}:00:00"
filewrf2="$dir_tmp/wrfout_d02_${year}-${month}-${day}_${hour}:00:00"

end_step=$(( forecast_length -1))

#set -x
# post 1km domain
domain="d02"
post_out=$dir_web/$domain
mkdir -p $post_out
$python $dir_post/plot_skewt.py $filewrf2 --start 6 --end $end_step --deltastep 6 --lat -26.315 --lon 31.133 --profilename 'Mbabane' --out $post_out
$python $dir_post/plot_figures.py $filewrf2 --start 6 --end $end_step --out $post_out --config $dir_post/var.yaml --deltastep 3

fig_meteo_archive=$dir_archive/$date_forecast/figures/$domain
mkdir -p $fig_meteo_archive
echo "copying figures to archive dir $fig_meteo_archive"
cd $post_out
for i in ${domain}*.png; do
  step=`echo $i |cut -d+ -f2 |cut -d. -f1`
  step=`printf '%02d\n' ${step}`
  field=`echo $i |cut -d+ -f1`
  new="${field}_${date_forecast}+${step}.png"
  cp $i $fig_meteo_archive/$new
done

#####create zip file with d02 plots ########
#####create zip file with d02 plots ########
#####create zip file with d02 plots ########
#####create zip file with d02 plots ########
cd $dir_script
$dir_script/crea_zip.sh $date_forecast
#####create zip file with d02 plots ########
#####create zip file with d02 plots ########
#####create zip file with d02 plots ########
#####create zip file with d02 plots ########

# post 5km domain
#domain="d01"
#post_out=$dir_web/$domain
#mkdir -p $post_out
#$python $dir_post/plot_skewt.py $filewrf1 --start 6 --end $end_step --deltastep 6 --lat -26.315 --lon 31.133 --profilename 'Mbabane' --out $post_out
#$python $dir_post/plot_figures.py $filewrf1 --start 6 --end $end_step --out $post_out --config $dir_post/vars.yaml --deltastep 3
#
#fig_meteo_archive=$dir_archive/$date_forecast/figures/$domain
#mkdir -p $fig_meteo_archive
#echo "copying figures to archive dir $fig_meteo_archive"
#cd $post_out
#for i in ${domain}*.png; do
#  step=`echo $i |cut -d+ -f2 |cut -d. -f1`
#  step=`printf '%02d\n' ${step}`
#  field=`echo $i |cut -d+ -f1`
#  new="${field}_${date_forecast}+${step}.png"
#  cp $i $fig_meteo_archive/$new
#done
