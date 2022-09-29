#!/bin/sh



# script to download GFS (including sst) data drom global forecast from the
# server https://nomads.ncep.noaa.gov


source settings
#set -x



#ncep archive 
path_gfs_ncep="https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/"

#alternative archive: ftpprd (contains last 10 days gfs forecasts)
#path_gfs_ncep="https://ftpprd.ncep.noaa.gov/data/nccf/com/gfs/prod/"


# if using date_forecast gfs (00Z)
date_forecast=`date -d "$date" +%Y%m%d` 

#date_forecast=20220515


# carefully check time scheduling, depending on what time the forecast
# is expected to be issued (if to use as init dategfs= date_forecast (00Z), or
# dategfs= date_forecast-1day (18Z))
datem1=`date -d "$date_forecast " +%d%m%Y00`
dategfs=`date -d "$date_forecast " +%Y%m%d`
#datem1=`date -d "$date_forecast -1 day" +%d%m%Y00`
#dategfs=`date -d "$date_forecast -1 day" +%Y%m%d`


#datesst=`date -d "$dategfs -1 day" +%Y%m%d`


# path for gfs filter (https://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25_1hr.pl)
URL1="https://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_${gfs_res}_1hr.pl?file=gfs.t${gfs_reference_time}z.pgrb2.${gfs_res}.f"
#URL2="&lev_0-0.1_m_below_ground=on&lev_0.1-0.4_m_below_ground=on&lev_0.4-1_m_below_ground=on&lev_1-2_m_below_ground=on&lev_1000_mb=on&lev_100_mb=on&lev_10_mb=on&lev_150_mb=on&lev_200_mb=on&lev_20_mb=on&lev_250_mb=on&lev_300_mb=on&lev_30_mb=on&lev_400_mb=on&lev_500_mb=on&lev_50_mb=on&lev_550_mb=on&lev_600_mb=on&lev_650_mb=on&lev_700_mb=on&lev_750_mb=on&lev_800_mb=on&lev_850_mb=on&lev_900_mb=on&lev_925_mb=on&all_var=on&subregion=&leftlon=15&rightlon=45&toplat=-15&bottomlat=-45&dir=%2Fgfs.${date_forecast}%2F${gfs_reference_time}%2Fatmos"
#URL2="&all_lev=on&all_var=on&subregion=&leftlon=15&rightlon=45&toplat=-15&bottomlat=-45&dir=%2Fgfs.${date_forecast}%2F${gfs_reference_time}%2Fatmos"
URL2="&lev_0-0.1_m_below_ground=on&lev_0.1-0.4_m_below_ground=on&lev_0.4-1_m_below_ground=on&lev_1000_mb=on&lev_100_mb=on&lev_50_mb=on&lev_1-2_m_below_ground=on&lev_150_mb=on&lev_1_hybrid_level=on&lev_200_mb=on&lev_250_mb=on&lev_300_mb=on&lev_350_mb=on&lev_400_mb=on&lev_450_mb=on&lev_500_mb=on&lev_550_mb=on&lev_600_mb=on&lev_650_mb=on&lev_700_mb=on&lev_750_mb=on&lev_800_mb=on&lev_850_mb=on&lev_900_mb=on&lev_925_mb=on&lev_950_mb=on&lev_975_mb=onlev_planetary_boundary_layer=on&lev_tropopause=on&lev_mean_sea_level=on&lev_surface=on&all_var=on&subregion=&leftlon=15&rightlon=45&toplat=-15&bottomlat=-45&dir=%2Fgfs.${date_forecast}%2F${gfs_reference_time}%2Fatmos"

# next two are functions to download gfs fields and sst, respectively:
 download_gfs () {

    #file_ncep=${file_prefix_ncep}.f${hhh}
    URL=${URL1}${hhh}${URL2}
    curl -k  $URL -o $file_ncep
    echo " curl -k  $URL -o $file_ncep"
    #file_ncep=${file_prefix_ncep}.f${hhh}
    #echo "wget -P $dir_gfs -c --no-check-certificate ${path_gfs_ncep}/gfs.${dategfs}/$gfs_reference_time/$file_ncep"
    #wget -P $dir_gfs -c --no-check-certificate ${path_gfs_ncep}/gfs.${dategfs}/$gfs_reference_time/atmos/$file_ncep
}

# download_sst () {
#
#  #echo "wget -P $dir_sst -c --no-check-certificate ${path_gfs_ncep}/sst.${datesst}/rtgssthr_grb_0.5.grib2"
#  wget -P $dir_sst -c --no-check-certificate ${path_gfs_ncep}/sst.${datesst}/rtgssthr_grb_0.5.grib2
#
#}



# start  download settings

file_prefix_ncep="gfs.t${gfs_reference_time}z.pgrb2.${gfs_res}"

#max attempts:
max_attempt=5


echo $ndays
hours=$(( ndays*24 + 3 )) # gfs forecast hours to be downloaded 
nfiles=$(( hours/3 +1 )) # number of expected 3-hourly files

#Download and Check if download complete, otherwise retry:
dir_gfs="$dir_input_meteo/${dategfs}_${gfs_reference_time}/"
#dir_sst="$dir_input_sst/${datesst}"
mkdir -p $dir_gfs
#mkdir -p $dir_sst


# call download functions for gfs fields and  sst
#  download_gfs $dir_gfs $hours ${dategfs} $gfs_reference_time $file_prefix_ncep
#  download_sst $dir_sst $hours ${datesst}


# CHECK  GFS data
# loops until complete nfiles are found
prefix_file_ncep="gfs.t${gfs_reference_time}z.pgrb2.${gfs_res}"
nf=`ls ${dir_gfs}/${prefix_file_ncep}.* | wc -l `
recnum=435
missing_record=1
echo ""
echo "Check downloaded GFS data in  $dir_gfs"

while [ $nf -lt "$nfiles" ] || [ $missing_record -eq "1" ]; do

  #check file number
  if [[ $nf == "$nfiles" ]];then
    echo "$nfiles files found... check if they are full ..."
    #check records (must be 743 each file)
    for hhh in `seq -f %03g 0 3 $hours`;do
      file_ncep=${dir_gfs}/${file_prefix_ncep}.f${hhh}
      num=`$dir_exe/wgrib2 -ftime $file_ncep | wc -l`
      # if finds incomplete file, retry download
      if [[ $num -ne $recnum ]];then
        missing_record=1
       echo "Incomplete file $file_ncep ... retry download... "
       download_gfs $file_ncep $hhh
       sleep 5
      else
        missing_record=0
      fi
    done # loop for content file check
    nf=`ls ${dir_gfs}/${prefix_file_ncep}.* | wc -l `

  else # less than expected nfiles, retry download
    echo "gfs file number differs from  $nfiles: actual files number $nf"
    echo "retry download..."
    for hhh in `seq -f %03g 0 3 $hours`;do
      file_ncep=${dir_gfs}/${file_prefix_ncep}.f${hhh}
      if [[ -f ${file_ncep} ]];then
        continue # jump to next file
      else
       download_gfs $file_ncep  $hhh
       sleep 5
      fi
    done 
    nf=`ls ${dir_gfs}/${prefix_file_ncep}.* | wc -l `
  fi

done
echo "CHECK  GFS  DATA OK: $nfiles files are present and not corrupted"
echo ""


#echo "CHECK  SST data  in $dir_input_sst/${datesst}"
#if [[ $count  -le $max_attempt ]]; then
#
#  #CHECK DATI SST
#  # essendo un unico file contenente solo un record, basta controllare che esista
#  # e non e' vuoto. Se non esiste o esiste ed e' vuoto, rilancio il downlad
#count=0
#  file_sst=$dir_input_sst/${datesst}/rtgssthr_grb_0.5.grib2
#  while [ $count -ne $max_attempt ];do
#
#    count=$((count + 1))
#    echo "SST attempt #$count ..."
#    if [ -s $file_sst ];then
#      echo "SST file exists and is not empty"
#      count=$max_attempt
#    else
#      echo "SST file unexistent or empty. retry download"
#      sleep 10
#      download_sst $dir_sst $hours ${datesst}
#    fi
#  done
#
#  echo ""
#fi
