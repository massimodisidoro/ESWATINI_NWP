#!/bin/bash

source settings

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
hour=$start_hour_forecast

filewrf="$dir_tmp/wrfout_d02_${year}-${month}-${day}_${hour}:00:00"

end_step=$(( forecast_length -1))

# post 1km domain
domain="d02"
post_out=$dir_post_out/$domain
mkdir -p $post_out

fig_meteo_archive=$dir_archive/${date_forecast}_${gfs_reference_time}/figures/
mkdir -p $fig_meteo_archive

#skewt
#$python $dir_post/plot_skewt.py $filewrf --start 6 --end $end_step --deltastep 6 --lat -26.315 --lon 31.133 --profilename 'Mbabane' --out $post_out

#set -x
#meteograms
#/gporq3/store_0/usr/disidoro/R_4.0.3/bin/Rscript $dir_post/meteogram.R --pathin $dir_tmp --date_forecast ${date_forecast}${gfs_reference_time} --out $fig_meteo_archive
#----------------------------------------
#problem in VM with cairo lib. Lancio in coda altrimenti non funziona
# da sistemare su HPC ESWATINI
scriptname="$dir_tmp/submit_meteogram_${date_forecast}.sh"
echo "#!/usr/bin/bash " > $scriptname
echo "module load gfortran_cr6 " >> $scriptname
#echo "set -x " >> $scriptname
echo "/gporq3/store_0/usr/disidoro/R_4.0.3/bin/Rscript $dir_post/meteogram.R --pathin $dir_tmp --date_forecast ${date_forecast}${gfs_reference_time} --out $fig_meteo_archive" >> $scriptname
echo "for file in $fig_meteo_archive/meteogram*.png;do " >> $scriptname
echo '  name=`basename $file` ' >> $scriptname
echo '  name_post=`echo $name |cut -d_ -f1-2`.png ' >> $scriptname
echo '  convert $file -resize 800X900 '"$post_out/"'$name_post ' >> $scriptname
echo "done " >> $scriptname

chmod +x $scriptname
out=$logdir/meteogram_${date_forecast}.out
err=$logdir/meteogram_${date_forecast}.err
bsub -W 180 -q  $queue_name_scalar -o $out -e $err $scriptname

#maps
$python $dir_post/plot_figures.py $filewrf --start 3 --end $end_step --out $post_out --config $dir_post/var.yaml --deltastep 3

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
