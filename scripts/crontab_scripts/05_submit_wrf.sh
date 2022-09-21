#!/usr/bin/pagsh
/usr/bin/kinit -k -t /etc/eswatini/keytab.aqforecast aqforecast
/usr/bin/aklog

source /etc/profile.d/modules.sh
. /afs/enea.it/profile/common/profile
source /etc/eswatini/settings

data=`date +%Y%m%d`

cd $dir_script  # senno' non funzione source ./env_vars dentro agli sctipts
mkdir -p $dir_log

./05-wrf.sh $data &>  $dir_log/log_05-wrf_${data}.log

#bsub -q $queue_name_serial -o $dir_log/log_03-real_${data}.out -e $dir_log/log_03-real_${data}.err ./04-real.sh $data

