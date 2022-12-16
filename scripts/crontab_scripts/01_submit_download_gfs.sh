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

$dir_script/01-download_gfs.sh &> $logdir/log_01-download_gfs_${data}.txt

