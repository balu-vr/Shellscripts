#!/bin/bash

cd /home/ec2-user/DataEngineering/oneplace/oneplace/

# Skip the job run if there is already an instance running..
#if [ -f output/refresh_acct_deal_tables.state ]; then
#    nowtime=`date +"%Y-%m-%d %H:%M:%S"`
#    prevjobtime=`stat output/refresh_acct_deal_tables.state |grep Modify|cut -c9-27`
#    echo "***** Script already running since $prevjobtime. So, skipping run at: $nowtime"
#    exit 1
#fi

# Start of new instance..
starttime=`date +"%Y-%m-%d %H:%M:%S"`
echo "###-###-###-###-###-### PRE PROCESS START OF LOG ###-###-###-###-###-###"
echo "$0 execution started... "
echo "Script starttime      : $starttime"

#touch output/refresh_acct_deal_tables.state

command() {
    echo $1 start
    sleep $(( $1 & 03 ))      # keep the seconds value within 0-3
    echo $1 complete
}

echo "Executing EDW tables loads.."
poetry run python OP_Extract_Incremental.py Account >> /home/ec2-user/DataEngineering/oneplace/logs/incremental_account.log &
sleep 10
poetry run python OP_Extract_Incremental.py Deal >> /home/ec2-user/DataEngineering/oneplace/logs/incremental_deal.log &
sleep 10
poetry run python OP_Extract_Incremental.py DLI >> /home/ec2-user/DataEngineering/oneplace/oneplace/incremental_dli.log &
sleep 10
poetry run python OP_Extract_Incremental.py DLIP >> /home/ec2-user/DataEngineering/oneplace/logs/incremental_dlip.log &
sleep 10
poetry run python OP_Extract_Incremental.py Product >> /home/ec2-user/DataEngineering/oneplace/logs/incremental_prod.log &
wait

#/usr/bin/python3 api_count.py > log/exec_api_count.log
dwscriptendtime=`date +"%Y-%m-%d %H:%M:%S"`
echo "Executing Data Model tables.. "
sh dim_account.sh &
sh dim_product.sh &
sh fact_acv_deals.sh &
sh fact_services_deals.sh &
wait
dmscriptendtime=`date +"%Y-%m-%d %H:%M:%S"`

echo "--- SUMMARY ---------------" >> logs/exec_duration.log
echo "EDW Script starttime      : $starttime" >> logs/exec_duration.log
echo "EDW Script endtime        : $dwscriptendtime" >> logs/exec_duration.log
echo "DataModel endtime         : $dmscriptendtime" >> logs/exec_duration.log
#cat log/exec_api_count.log >> logs/exec_duration.log
#sh edw_count.sh >> logs/exec_duration.log
/usr/bin/python3 exec_count_match.py >> logs/exec_duration.log
scriptendtime=`date +"%Y-%m-%d %H:%M:%S"`
echo "Script endtime            : $scriptendtime" >> logs/exec_duration.log
echo "---------------------------" >> logs/exec_duration.log

echo "$starttime|$dwscriptendtime|$dmscriptendtime|$scriptendtime" >> logs/duration.log

echo "--- SUMMARY ---------------"
echo "EDW Script starttime      : $starttime"
echo "EDW Script endtime        : $dwscriptendtime"
echo "DataModel endtime         : $dmscriptendtime"
echo "API Count..."
#cat log/exec_api_count.log
echo "Script endtime            : $scriptendtime"
echo "---------------------------"
#rm output/refresh_acct_deal_tables.state
echo "###-###-###-###-###-### PRE PROCESS END OF LOG ###-###-###-###-###-###"
exit 0

