#!/bin/bash

source settings

date_forecast=$1

if [[ -z $date_forecast ]];then
  date_forecast=`date +%Y%m%d`
  echo " date_forecast not provided, starting with $date_forecast"
fi


mkdir -p $dir_log
mkdir -p $dir_tmp

run_hours=$(( ndays*24 ))
end_date=`date -d "$date_forecast +$run_hours hours" +%Y%m%d`


#formate dates for wrf WRF namelist
yyyy1=`echo $date_forecast |cut -c 1-4`
mm1=`echo $date_forecast |cut -c 5-6`
dd1=`echo $date_forecast |cut -c 7-8`
hh1=$start_hour_forecast

yyyy2=`echo $end_date |cut -c 1-4`
mm2=`echo $end_date |cut -c 5-6`
dd2=`echo $end_date |cut -c 7-8`
hh2=$end_hour_forecast



cp $dir_namelist/namelist.input.tpl $dir_tmp

cd $dir_tmp

ln -sf $dir_exe/wrf.exe .
ln -sf $dir_wrf_run_data/aerosol* .
ln -sf $dir_wrf_run_data/bulk* .
ln -sf $dir_wrf_run_data/C* .
ln -sf $dir_wrf_run_data/*.asc .
ln -sf $dir_wrf_run_data/kernels.asc_s_0_03_0_9 .
ln -sf $dir_wrf_run_data/ETAMPNEW_DATA .
ln -sf $dir_wrf_run_data/ETAMPNEW_DATA.expanded_rain .
ln -sf $dir_wrf_run_data/grib* .
ln -sf $dir_wrf_run_data/GENPARM.TBL .
ln -sf $dir_wrf_run_data/LANDUSE.TBL .
ln -sf $dir_wrf_run_data/MPTABLE.TBL .
ln -sf $dir_wrf_run_data/SOILPARM.TBL .
ln -sf $dir_wrf_run_data/URBPARM.TBL .
ln -sf $dir_wrf_run_data/VEGPARM.TBL .
ln -sf $dir_wrf_run_data/RRTM* .
ln -sf $dir_wrf_run_data/tr* .
ln -sf $dir_wrf_run_data/ozone* .
ln -sf $dir_wrf_run_data/p3_lookup_table_1.dat .
ln -sf $dir_wrf_run_data/README.namelist .


cat namelist.input.tpl | \
sed "s/yyyy1/${yyyy1}/g" | \
sed "s/mm1/${mm1}/g" | \
sed "s/dd1/${dd1}/g" | \
sed "s/hh1/${hh1}/g" | \
sed "s/yyyy2/${yyyy2}/g" | \
sed "s/mm2/${mm2}/g" | \
sed "s/dd2/${dd2}/g" | \
sed "s/hh2/${hh2}/g" >  namelist.input

#prepare script for wrf run
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
echo "mv rsl* $dir_log"  >>  $script_wrf
echo "cp namelist.input $dir_log/namelist.input_$date_forecast"  >>  $script_wrf

chmod 744 $script_wrf
bsub  -n $nprocs_wrf -q $queue_name_parallel -o $dir_log/wrf_${date_forecast}.out -e $dir_log/wrf_${date_forecast}.err $script_wrf $cpu_omp $log
