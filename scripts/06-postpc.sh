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
#done # cycle over both domains (5km and 1 km resolution)


  #transfer plots to windows machine
   #folder name on remote machine to which put the data
   folder=${date_forecast}_${gfs_reference_time}_d${domain}
  
   # build tmp.txt file containing the list of files to be transferred
   find $fig_meteo_archive/ -type f -name "d${domain}*" | xargs -I {} basename {} > tmp.txt
   #ls -1 $fig_meteo_archive/d${domain}* > tmp.txt
   if [[ $domain == "02" ]];then
     find $fig_meteo_archive/ -type f -name "meteogram*"  | xargs -I {} basename {} >> txt.txt
     #ls -1 $fig_meteo_archive/meteogram* >> tmp.txt
   fi

  # UPLOAD graphical output to remote machine
  # NOTE that remote machine and its path are defined in "settings" file.
   #create remote folder where to copy files
   rclone mkdir ${remote_machine}:${remote_folder_path}/$folder
   # copy files to remote folder
   rclone copy $fig_meteo_archive ${remote_machine}:${remote_folder_path}/$folder --include-from=tmp.txt
   #remove remote folder than remote_folder_age (this key is defined in settings, in days)
   rclone lsf $remote_machine:${remote_folder_path} --dirs-only --format tp  | while read string; do
   folder=$(echo $string |cut -d';' -f2)
   folder_date=$(echo $string |cut -d';' -f1)
   #echo $folder $folder_date
    if [ ! -z "$folder_date" ]; then
      folder_timestamp=$(date -d "$folder_date" +%s)
      current_timestamp=$(date +%s)
      age=$(( (current_timestamp - folder_timestamp) / 86400 )) # expressed in days (integer part)
      if [ "$age" -gt "$remote_folder_age" ]; then
        echo "Deleting: $folder"
        rclone purge $remote_machine:${remote_folder_path}/$folder --dry-run
      fi
    fi
   done

  #transfer test on enea  machine
  rclone mkdir enea://gporq3/minni/minniusers/disidoro/tmp/$folder -vv
  rclone copy $fig_meteo_archive enea:/gporq3/minni/minniusers/disidoro/tmp/$folder --include-from=tmp.txt -vv
  rm tmp.txt
done # cycle over both domains (5km and 1 km resolution)
