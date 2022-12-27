#!/bin/bash

source settings

date_forecast=$1

if [[ -z $date_forecast ]];then
  date_forecast=`date +%Y%m%d`
  echo " date_forecast not provided, starting with $date_forecast"
fi

logdir=$dir_log/$date_forecast

mkdir -p $logdir
mkdir -p $dir_tmp

run_hours=$forecast_length
ts_buffer=`echo "scale=0; 6 * 3600 / $wrf_timestep"|bc` # every 6 hours updates timeseries
frames_wrfout=`echo "scale=0; $run_hours +1"|bc`

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



###########################################################
# in tepria qua sotto non bisogna toccare nulla 
# in quanto tutto e' guidato da variabili sopra. A meno che
# non vadano cambiato i path di input/output/exe
###########################################################
 cp $dir_namelist/namelist.input.tpl $dir_tmp

cd $dir_tmp

ln -sf $dir_exe/real.exe .


ln -sf $dir_geogrid_files/* .



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

#preparo scritp lancio real
script_real=script_real.exe
echo '#!/bin/sh' > $script_real
echo "sleep 3" >>$script_real

#link met_em
#loop=$date
#while [[ $loop -le `echo $end_date|cut -c 1-8` ]];do
  #year=`echo $loop | cut -c 1-4`
  #month=`echo $loop | cut -c 5-6`
  #day=`echo $loop | cut -c 7-8`
  #echo "ln -sf $dir_metgrid_files/met_em*${year}-${month}-${day}* ." >>$script_real
   #loop=`date -d "$loop +1 day" +%Y%m%d`
#done

./real.exe #&> $logdir/log_04_real_${date_forecast}.log

#echo 'NCPUS=1 ; export NCPUS' >> $script_real
#echo 'OMP_NUM_THREADS=1 ; export OMP_NUM_THREADS' >> $script_real
#echo 'ulimit -s unlimited' >> $script_real
#echo 'HOSTFILE=$LSB_DJOB_HOSTFILE' >> $script_real
#echo 'N_procs=`cat $LSB_DJOB_HOSTFILE | wc -l`' >> $script_real
#echo 'mpirun --bind-to socket --mca plm_rsh_agent "blaunch.sh" -n $N_procs --hostfile $HOSTFILE ./real.exe' >> $script_real
#echo 'sleep 5' >> $script_real
#echo "mv rsl* $logdir/real_${date_forecast}.log" >> $script_real
#echo "rm met_em*.nc" >> $script_real
#echo "cp namelist.input $logdir/namelist.input_real_$date_forecast" >> $script_real
#
##lancio real
#bsub -We $We_real -n  $nprocs_real -q $queue_name_parallel -o $logdir/real_${date_forecast}.out -e $logdir/real_${date_forecast}.err  $script_real
#
