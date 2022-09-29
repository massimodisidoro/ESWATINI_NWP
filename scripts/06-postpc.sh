#!/bin/bash

source settings

date_forecast=$1

if [[ -z $date_forecast ]];then
  date_forecast=`date +%Y%m%d`
  echo " date_forecast not provided, starting with today: $date_forecast"
fi


mkdir -p $dir_log
mkdir -p $dir_tmp

year=`date -d "$date_forecast" +%Y`
month=`date -d "$date_forecast" +%m`
day=`date -d "$date_forecast" +%d`
hour=`date -d "$date_forecast" +%H`

filewrf1="$dir_tmp/wrfout_d01_${year}-${month}-${day}_${hour}:00:00"
filewrf2="$dir_tmp/wrfout_d02_${year}-${month}-${day}_${hour}:00:00"

end_step=$(( ndays * 24 ))

post_out=$dir_tmp
# post d01
#$python $dir_post/plot_figures.py $filewrf1 --start 1 --end $end_step --out $post_out
# post d02
#$python $dir_post/plot_figures.py $filewrf1 --start 1 --end $end_step --out $post_out
$python $dir_post/plot_figures.py $filewrf2 --start 1 --end 48 --out $post_out

# archive
fig_archive=$dir_archive/$date_forecast/figures
mkdir -p $fig_archive
mv $dir_tmp/*init_${date_forecast}_*.png  $fig_archive

#### to local website 
cd $fig_archive
for i in *.png; do
  pre=`echo $i | awk -F'_init' '{print $1}'`
  suff="`echo $i | rev |cut -d+ -f 1 |rev |cut -d. -f 1`"
  xx=`printf '%02d\n' ${suff}`
  new="${pre}+${xx}.png"
  cp $i /afs/enea.it/bol/user/disidoro/public_html/enwp/d2/$new
done

