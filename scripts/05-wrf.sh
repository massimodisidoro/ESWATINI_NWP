#!/bin/bash

#set -x
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
dir_log="$dir_archive/${date_forecast}_${gfs_reference_time}/log"
dir_metgrid_files="$dir_tmp"
mkdir -p $dir_tmp $dir_log $dir_metgrid_files


run_hours=$forecast_length
ts_buffer=`echo "scale=0; 6 * 3600 / $wrf_timestep"|bc` # every 6 hours dumps  timeseries buffer to file
frames_wrfout=`echo "scale=0; $run_hours +1"|bc`
end_date=`date -d "$date_forecast +$run_hours hours" +%Y%m%d`

#format initial and end dates for wrf WRF namelist
yyyy1=`echo $date_forecast |cut -c 1-4`
mm1=`echo $date_forecast |cut -c 5-6`
dd1=`echo $date_forecast |cut -c 7-8`
hh1=$gfs_reference_time

yyyy2=`echo $end_date |cut -c 1-4`
mm2=`echo $end_date |cut -c 5-6`
dd2=`echo $end_date |cut -c 7-8`
hh2=`date -d "$date_forecast + $run_hours hour" +%H`
if [[ $gfs_reference_time != "00" ]];then
  hh2=$(( $hh2 + $gfs_reference_time ))
fi



cp $dir_namelist/namelist.input.tpl $dir_tmp
cp $dir_post/tslist $dir_tmp
cp $dir_script/hostfile $dir_tmp

cd $dir_tmp

#link executable and README.namelist
#ln -sf $dir_exe/wrf.exe 
ln -sf $dir_wrf_lookup_tables/README.namelist 
#according to README.physics_files, link the necessary files 
#needed by the physics configuragion chosen.
#needed for NOAH soil (option 2)
ln -sf $dir_wrf_lookup_tables/LANDUSE.TBL 
ln -sf $dir_wrf_lookup_tables/GENPARM.TBL 
ln -sf $dir_wrf_lookup_tables/SOILPARM.TBL 
ln -sf $dir_wrf_lookup_tables/VEGPARM.TBL 
#needed for radiation option 4 (RRTMG)
ln -sf $dir_wrf_lookup_tables/RRTMG_LW_DATA
ln -sf $dir_wrf_lookup_tables/RRTMG_LW_DATA_DBL
ln -sf $dir_wrf_lookup_tables/RRTMG_SW_DATA
ln -sf $dir_wrf_lookup_tables/RRTMG_SW_DATA_DBL
ln -sf $dir_wrf_lookup_tables/aerosol.formatted
ln -sf $dir_wrf_lookup_tables/aerosol_lat.formatted
ln -sf $dir_wrf_lookup_tables/aerosol_lon.formatted
ln -sf $dir_wrf_lookup_tables/aerosol_plev.formatted
ln -sf $dir_wrf_lookup_tables/ozone.formatted
ln -sf $dir_wrf_lookup_tables/ozone_lat.formatted
ln -sf $dir_wrf_lookup_tables/ozone_plev.formatted
ln -sf $dir_wrf_lookup_tables/CAMtr_volume_mixing_ratio

# build the namelist.input from template
cat namelist.input.tpl | \
sed "s/@@ts_buf_size@@/${ts_buffer}/g" | \
sed "s/@@wrf_timestep@@/${wrf_timestep}/g" | \
sed "s/@@adaptive_timestep@@/${adaptive_timestep}/g" | \
sed "s/@@frames_wrfout@@/${frames_wrfout}/g" | \
sed "s/yyyy1/${yyyy1}/g" | \
sed "s/mm1/${mm1}/g" | \
sed "s/dd1/${dd1}/g" | \
sed "s/hh1/${hh1}/g" | \
sed "s/yyyy2/${yyyy2}/g" | \
sed "s/mm2/${mm2}/g" | \
sed "s/dd2/${dd2}/g" | \
sed "s/hh2/${hh2}/g" >  namelist.input
set -x

export OMP_NUM_THREADS=$omp_wrf_threads
mpirun -np $nprocs_wrf --hostfile $dir_tmp/hostfile $dir_exe/wrf.exe &> $dir_log/log_05-wrf_${date_forecast}.log
#mpirun -np $nprocs_wrf $dir_exe/wrf.exe &> $dir_log/log_05-wrf_${date_forecast}.log
cp namelist.input $dir_log/namelist.input_$date_forecast
mkdir -p $dir_log/wrflog
cp rsl* $dir_log/wrflog
cp wrfout*d0* $dir_archive/${date_forecast}_${gfs_reference_time}

