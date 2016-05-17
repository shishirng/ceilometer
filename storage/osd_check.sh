#!/bin/bash

source ./common/cephlogmgr.sh
set -x 
function notify_thru_email_30()
{
	cat $2 |mail -s "[PROD]$1" -a "From: jcs.sbsnotifications@zmail.ril.com" shishir.gowda@ril.com
}


function notify_thru_email()
{
#	cat $2 |mail -s "[PROD_TEST]$1" -a "From: jcs.sbsnotifications@zmail.ril.com" sandeep41.kumar@ril.com
	cat $2 |mail -s "[PROD]$1" -a "From: jcs.sbsnotifications@zmail.ril.com" shishir.gowda@ril.com chirag.aggarwal@ril.com rahul4.jain@ril.com ravikanth.maddikonda@ril.com vivek.kayarohanam@ril.com sandeep41.kumar@ril.com souvik.ray@ril.com
}

ceph_health_timeout=30
script_sleep_min=5
curr_sleep_interval=$script_sleep_min
max_failures=5
max_script_interval=60
#3600
failures=0
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
	    echo -n "Ceph OSD Down " >> /tmp/ceph.osd.health
	    echo >> /tmp/ceph.osd.health
	    notify_thru_email "Ceph OSD Alert!" /tmp/ceph.osd.health
            failures=$(($failures+1))
	else
            if (( $failures != 0 ))
            then
		echo -n "Ceph OSD is healthy" >> /tmp/ceph.osd.health
		echo >> /tmp/ceph.osd.health
                notify_thru_email "Ceph OSD Up" /tmp/ceph.osd.health
            fi
	    failures=0
	fi
        if (($failures>=$max_failures))
        then
                echo "Delay the script" 

                if (($curr_sleep_interval>=$max_script_interval))
                then
                        curr_sleep_interval=$max_script_interval
                else
                        curr_sleep_interval=$(($curr_sleep_interval*2))
                fi
        fi

	script_sleep_duration=`echo "$curr_sleep_interval""m"`
        sleep $script_sleep_duration

done

