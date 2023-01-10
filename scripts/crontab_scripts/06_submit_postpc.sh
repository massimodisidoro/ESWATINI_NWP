#!/usr/bin/pagsh
/usr/bin/kinit -k -t /etc/eswatini/keytab.aqforecast aqforecast
/usr/bin/aklog

source /etc/profile.d/modules.sh
. /afs/enea.it/profile/common/profile
source /etc/eswatini/settings

echo "POSTPC STARTING..."
data=`date +%Y%m%d`
logdir=$dir_log/$data
mkdir -p $logdir

cd $dir_script  # senno' non funzione source ./env_vars dentro agli sctipts

#bsub -q $queue_name_scalar -o $logdir/log_06-postpc_${data}.out -e $logdir/log_06-postpc_${data}.err ./06-postpc.sh $data
$dir_script/06-postpc.sh $data &> $logdir/log_06-postpc_${data}.log 

