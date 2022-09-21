#!/usr/bin/pagsh
/usr/bin/kinit -k -t /etc/eswatini/keytab.aqforecast aqforecast
/usr/bin/aklog

source /etc/profile.d/modules.sh
. /afs/enea.it/profile/common/profile
source /etc/eswatini/settings
data=`date +%Y%m%d` # to be put in settings? It depends of forecast scheduling


cd $dir_script 

$dir_script/clear_old_files.sh > $dir_log/clean_old_files_$data
