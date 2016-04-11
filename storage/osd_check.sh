#!/bin/bash

source ./common/cephlogmgr.sh
set -x 
function notify_thru_email_30()
{
	cat $2 |mail -s "[PROD]$1" -a "From: shishir.gowda@ril.com" shishir.gowda@ril.com
}


function notify_thru_email()
{
	#cat $2 |mail -s "[PROD_TEST]$1" -a "From: shishir.gowda@ril.com" shishir.gowda@ril.com
	cat $2 |mail -s "[PROD]$1" -a "From: shishir.gowda@ril.com" shishir.gowda@ril.com chirag.aggarwal@ril.com rahul4.jain@ril.com ravikanth.maddikonda@ril.com vivek.kayarohanam@ril.com sandeep41.kumar@ril.com
}

ceph_health_timeout=30
script_sleep_min=5
latency_threshold=40.0 #ms
counter=0
mail_interval=24
declare -A arrLTotal
declare -A arrLOps

while :

do
	rm -rf /tmp/ceph.osd.health
	TIMEDOUT=0

	# check ceph health
	HEALTH=$(timeout $ceph_health_timeout sudo ceph -s |grep osdmap|awk '{print $3==$5}')
	if [ "$?" = 124 ]
	then
	    HEALTH="ceph health timed out ($ceph_health_timeout seconds), potential loss of quorum!"
	    TIMEDOUT=1
	fi

	if (( $HEALTH != 1 )) 
	then
	    echo -n "Ceph OSD down healthy " >> /tmp/ceph.osd.health
	    echo >> /tmp/ceph.osdhealth
	    notify_thru_email "Ceph OSD Alert!" /tmp/ceph.osd.health
	fi

	script_sleep_duration=`echo "$script_sleep_min""m"`
        sleep $script_sleep_duration

done

