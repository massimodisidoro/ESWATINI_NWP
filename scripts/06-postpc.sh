#!/bin/bash
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
date_forecastm1=`date -d "$date_forecast -1 day" +%Y%m%d`

dir_tmp="$dir_root/scratch_${gfs_reference_time}UTC"
dir_metgrid_files="$dir_tmp"
dir_log="$dir_archive/${date_forecast}_${gfs_reference_time}/log"
mkdir -p $dir_tmp $dir_log $dir_metgrid_files


year=`date -d "$date_forecast" +%Y`
month=`date -d "$date_forecast" +%m`
day=`date -d "$date_forecast" +%d`
hour=$gfs_reference_time


#check if wrf successfully ended and clean wrf.exe processes if any:
count=0
filelog=$dir_tmp/rsl.out.0000
while [[ $count -le 90 ]];do
  testme=` cat $filelog |grep "SUCCESS COMPLETE WRF"`
  echo "testing WRF complete ... $count"
  if [[ $testme == "wrf: SUCCESS COMPLETE WRF" ]];then
    echo "WRF COMPLETED "
    pkill wrf.exe
    sleep 10
    break
  fi
  sleep 60
  count=$(( $count +1 ))
done
  
# mettere ciclo su d1 e d2 e per d1 non fare meteogrammi e profili ma solo mappe
# mettere ciclo su d1 e d2 e per d1 non fare meteogrammi e profili ma solo mappe
# mettere ciclo su d1 e d2 e per d1 non fare meteogrammi e profili ma solo mappe
# mettere ciclo su d1 e d2 e per d1 non fare meteogrammi e profili ma solo mappe
# mettere ciclo su d1 e d2 e per d1 non fare meteogrammi e profili ma solo mappe
# mettere ciclo su d1 e d2 e per d1 non fare meteogrammi e profili ma solo mappe
# mettere ciclo su d1 e d2 e per d1 non fare meteogrammi e profili ma solo mappe
#start postproc procedure 
for domain in 02 01;do
  filewrf="$dir_archive/${date_forecast}_${gfs_reference_time}/wrfout_d${domain}_${year}-${month}-${day}_${hour}:00:00"

  if [[ ! -f $filewrf ]];then
    echo "wrf file $filewrf not found"
    echo "EXIT procedure"
  fi
  
  
  end_step=$(( forecast_length +1))
  
  
  fig_meteo_archive=$dir_archive/${date_forecast}_${gfs_reference_time}/figures/
  mkdir -p $fig_meteo_archive
  
  if [[ $domain == "02" ]];then
    #skewt plots
    tmpfile=$dir_tmp/tmpfile
    cat $dir_post/tslist | grep -v "#" > $tmpfile
    while read name prefix lat lon;do
      name=`echo $name |sed "s/_/ /g"`
      $python $dir_post/plot_skewt.py $filewrf --start 3 --end $end_step --deltastep $deltastep_maps --lat $lat --lon $lon --profilename "$name" --out $fig_meteo_archive
    done < $tmpfile
    rm $tmpfile

    #meteograms
    Rscript $dir_post/meteogram.R --pathin $dir_tmp --date_forecast ${date_forecast}${gfs_reference_time} --out $fig_meteo_archive
  fi #profiles and meteograms only for hres domain (02)
  
  #maps
  $python $dir_post/plot_figures.py $filewrf --start 3 --end $end_step --out $fig_meteo_archive --config $dir_post/var.yaml --deltastep $deltastep_maps
done # cycle over both domains (5km and 1 km resolution)


#transfer plots to windows machine
 #folder name on remote machine
 folder=${date_forecast}_${gfs_reference_time}
 yesterday_folder=${date_forecastm1}_$gfs_reference_time
 # build list with files to be transferred
 ls -1 $fig_meteo_archive > tmp.txt

# IF CHANGE DESTINATION MACHINE IS NEEDED, THE FOLLOWING
# THREE rclone COMMANDS MUST BE UPDATED, AFTER CONFIGURING THE
# NEW DESTINATION WITH "rclone config"
 #create remote folder where to copy files
 rclone mkdir sive_windows_machine:C:/Users/Met/Desktop/ENEA/$folder
 # copy files to remote folder
 rclone copy $fig_meteo_archive sive_windows_machine:C:/Users/Met/Desktop/ENEA/$folder --include-from=tmp.txt
 #remove remote folder containing yesterday forecasts
 rclone purge sive_windows_machine:C:/Users/Met/Desktop/ENEA/$yesterday_folder

#transfer test on enea  machine
#rclone mkdir enea://gporq3/minni/minniusers/disidoro/tmp/$folder -vv
#rclone copy $fig_meteo_archive enea:/gporq3/minni/minniusers/disidoro/tmp/$folder --include-from=tmp.txt -vv
rm tmp.txt
