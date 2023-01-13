#!/bin/bash

#set -x
source settings

date_forecast=$1

if [[ -z $date_forecast ]];then
  date_forecast=`date +%Y%m%d`
  echo " date_forecast not provided, starting with $date_forecast"
fi

logdir=$dir_log/$date_forecast

mkdir -p $logdir/wrflog
mkdir -p $dir_tmp

run_hours=$forecast_length
ts_buffer=`echo "scale=0; 6 * 3600 / $wrf_timestep"|bc` # every 6 hours dumps  timeseries buffer to file
frames_wrfout=`echo "scale=0; $run_hours +1"|bc`
end_date=`date -d "$date_forecast +$run_hours hours" +%Y%m%d`

#format initial and end dates for wrf WRF namelist
yyyy1=`echo $date_forecast |cut -c 1-4`
mm1=`echo $date_forecast |cut -c 5-6`
dd1=`echo $date_forecast |cut -c 7-8`
hh1=$start_hour_forecast

yyyy2=`echo $end_date |cut -c 1-4`
mm2=`echo $end_date |cut -c 5-6`
dd2=`echo $end_date |cut -c 7-8`
hh2=`date -d "$date_forecast + $run_hours hour" +%H`


cp $dir_namelist/namelist.input.tpl $dir_tmp
cp $dir_post/tslist $dir_tmp

cd $dir_tmp

#link executable and README.namelist
ln -sf $dir_exe/wrf.exe 
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

#prepare script for wrf run
# to be modified on Eswatini HPC as_ mpirun -n ncores --hostfile hosts.txt
# where hosts.txt will contain the names oh the 4 nodes
script_wrf=script_wrf.exe
echo '#!/bin/sh' > $script_wrf
echo "date=$date_forecast" >>$script_wrf
echo 'export OMP_NUM_THREADS=$1' >> $script_wrf
echo 'exe=./wrf.exe ' >> $script_wrf
echo "slots=\`awk 'END{print NR}' \$LSB_DJOB_HOSTFILE\`"  >> $script_wrf
echo 'N_procs=`echo "$slots/$OMP_NUM_THREADS" | bc`' >> $script_wrf
echo 'N_procs_host=`echo "$N_procs/$(sort -u $LSB_DJOB_HOSTFILE | wc -l)" | bc`' >> $script_wrf
echo 'for host in `sort -u $LSB_DJOB_HOSTFILE`' >> $script_wrf
echo 'do' >> $script_wrf
echo 'for proc in `seq 1 $N_procs_host`' >> $script_wrf
echo 'do' >> $script_wrf
echo 'echo $host >> ./hosts.${LSB_JOBID}_$date' >> $script_wrf
echo 'done' >> $script_wrf
echo 'done' >> $script_wrf
echo 'mpirun --bind-to socket --mca plm_rsh_agent "blaunch.sh" -n $N_procs --hostfile ./hosts.${LSB_JOBID}_$date $exe' >> $script_wrf
echo 'sleep 5' >> $script_wrf
echo "mv rsl* $logdir/wrflog"  >>  $script_wrf
echo "cp namelist.input $logdir/namelist.input_$date_forecast"  >>  $script_wrf

chmod 744 $script_wrf
bsub  -n $nprocs_wrf -q $queue_name_parallel -o $logdir/log_05-wrf_${date_forecast}.out -e $logdir/log_05-wrf_${date_forecast}.err $script_wrf $cpu_omp $log
