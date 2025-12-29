#!/bin/bash

set -e
set -u

export PGHOST=${PGHOST-intapp-bi.intapp.net}
export PGPORT=${PGPORT-5439}
export PGDATABASE=''
export PGUSER=''
export PGPASSWORD=''

#export PGDATABASE=${PGDATABASE-intappbi}
#export PGUSER=${PGUSER-intapp}
#export PGPASSWORD=${PGPASSWORD-U2vSQn!92\$pB}


date=`date +%F -d "yesterday"`
echo "$0 script started at `date +"%F %T"`"
RUN_PSQL="psql -X " 

${RUN_PSQL} <<SQL	

refresh materialized view analytics.fact_acv_deals;  
refresh materialized view analytics.fact_css_task;

SQL

if [ "$?" != 0 ]; then
    echo "psql failed while trying to run this sql script" 1>&2
    sudo sendmail -v  -s "$0 Materialize view script Failed:$date" "jorge.herrera@intapp.com;jorge.herrera@intapp.com"  
    exit 1
fi

echo "$0 script successful at `date +"%F %T"`"
exit 0
