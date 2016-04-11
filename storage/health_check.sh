#!/bin/bash

source ./common/cephlogmgr.sh

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
script_sleep_min=30
latency_threshold=40.0 #ms
counter=0
mail_interval=24
declare -A arrLTotal
declare -A arrLOps

while :

do
	rm -f /tmp/ceph.log.today
	rm -f /tmp/ceph.log.tail
	rm -f /tmp/ceph.log.warnings
	rm -f /tmp/ceph.log.health
	rm -f /tmp/ceph.log.nearfull
	rm -f /tmp/ceph.log.latency
	
	TIMEDOUT=0

	# check ceph health
	HEALTH=$(timeout $ceph_health_timeout sudo ceph health)
	if [ "$?" = 124 ]
	then
	    HEALTH="ceph health timed out ($ceph_health_timeout seconds), potential loss of quorum!"
	    TIMEDOUT=1
	fi

	if [ "$HEALTH" != 'HEALTH_OK' ]
	then
	    echo -n "Ceph is not healthy: " >> /tmp/ceph.log.health
	    echo "$HEALTH" >> /tmp/ceph.log.health
	    echo >> /tmp/ceph.log.health
	    notify_thru_email "Ceph Health Alert!" /tmp/ceph.log.health
	else
	    echo -n "Ceph is healthy: " >> /tmp/ceph.log.health
	    if (( $counter % $mail_interval == 0)) 
            then
	    	notify_thru_email "Ceph Health OK!" /tmp/ceph.log.health
		if (( $counter == $mail_interval ))
		then
			echo "resetting counter to 0"
			counter=0
		fi
	    else
		notify_thru_email_30 "Ceph Health OK!" /tmp/ceph.log.health
	    fi
	fi
	echo "Incrementing counter"
	counter=$((counter + 1))

	if [ $TIMEDOUT -eq 0 ] 
	then
		NEARFULL=`timeout $ceph_health_timeout sudo ceph -s -f json | jq .osdmap.osdmap.nearfull`

		if [ "$NEARFULL" != "false" ] 
		then
			timeout $ceph_health_timeout sudo ceph -s -f json | jq .osdmap.osdmap > /tmp/ceph.log.nearfull
			notify_thru_email "Ceph Nearfull Alert!" /tmp/ceph.log.nearfull
		fi

	fi

        start_rcv_log /tmp/ceph.log.copy

	script_sleep_duration=`echo "$script_sleep_min""m"`
        sleep $script_sleep_duration

	stop_rcv_log

        WARNINGS=$(grep WRN /tmp/ceph.log.copy)
	if [ "$WARNINGS" ]
	then
	    echo -n "Warnings in ceph.log: " >> /tmp/ceph.log.warnings
	    echo "$WARNINGS"|wc -l >> /tmp/ceph.log.warnings
	    grep -v INF /tmp/ceph.log.copy >> /tmp/ceph.log.warnings
	    echo  >> /tmp/ceph.log.warnings
	    notify_thru_email "Ceph Warnings Alert!" /tmp/ceph.log.warnings
	fi
	
	
done

