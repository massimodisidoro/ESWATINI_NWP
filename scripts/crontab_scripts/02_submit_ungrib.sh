#!/usr/bin/pagsh
/usr/bin/kinit -k -t /etc/eswatini/keytab.aqforecast aqforecast
/usr/bin/aklog

source /etc/profile.d/modules.sh
. /afs/enea.it/profile/common/profile
source /etc/eswatini/settings

data=`date +%Y%m%d` # to be put in settings? It depends of forecast scheduling
logdir=$dir_log/$data
mkdir -p $logdir

cd $dir_script  # senno' non funzione source ./env_vars dentro agli sctipts

bsub -q $queue_name_scalar -o $logdir/log_02-ungrib_${data}.out -e $logdir/log_02-ungrib_${data}.err ./02-ungrib.sh $data

# non funziona perche' vm non vede la csh per ./link_grib.csh
#./02-ungrib.sh $data &>  $dir_tmp/ungrib/log_02-ungrib_${data}.log

