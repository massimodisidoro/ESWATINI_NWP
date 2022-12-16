#!/usr/bin/pagsh
/usr/bin/kinit -k -t /etc/eswatini/keytab.aqforecast aqforecast
/usr/bin/aklog

source /etc/profile.d/modules.sh
. /afs/enea.it/profile/common/profile
source /etc/eswatini/settings

data=`date +%Y%m%d`
logdir=$dir_log/$data
mkdir -p $logdir

cd $dir_script  # senno' non funzione source ./env_vars dentro agli sctipts

./05-wrf.sh $data &>  $logdir/log_05-wrf_${data}.log

#bsub -q $queue_name_serial -o $logdir/log_03-real_${data}.out -e $logdir/log_03-real_${data}.err ./04-real.sh $data

