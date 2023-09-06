#!/bin/bash

export python=/storage/forecast_system/libs/anaconda3/wrf-python/bin/python
export deltastep_maps=3



dir_work="./"


year=`date -d "$date_forecast" +%Y`
month=`date -d "$date_forecast" +%m`
day=`date -d "$date_forecast" +%d`
hour=$gfs_reference_time


dir_plots=$dir_work/plots
mkdir -p $dir_plots
end_step=$(( 24 +1))

#start postproc procedure 
for domain in 02 01;do
  filewrf=$( ls ../wrfout_d${domain}* )

  date_forecast=$( echo $filewrf | cut -d_ -f 3 |sed "s/-//g" )
  gfs_reference_time=$( echo $filewrf | cut -d_ -f 4 |cut -c 1-2 )
  date_forecastm1=`date -d "$date_forecast -1 day" +%Y%m%d`
  if [[ $domain == "02" ]];then
    #skewt plots
    tmpfile=$dir_work/tmpfile
    cat $dir_work/tslist | grep -v "#" > $dir_work/$tmpfile
    while read name prefix lat lon;do
      name=`echo $name |sed "s/_/ /g"`
      $python ./plot_skewt.py $filewrf --start 3 --end $end_step --deltastep $deltastep_maps --lat $lat --lon $lon --profilename "$name" --out $dir_plots
    done < $tmpfile
    rm $tmpfile

    #meteograms
    Rscript ./meteogram.R --pathin $dir_work --date_forecast ${date_forecast}${gfs_reference_time} --out $dir_plots
  fi #profiles and meteograms only for hres domain (02)
  
  #maps
  $python ./plot_figures.py $filewrf --start 3 --end $end_step --out $dir_plots --config var.yaml --deltastep $deltastep_maps

done # cycle over both domains (5km and 1 km resolution)

display -resize 60% $dir_plots/*.png
