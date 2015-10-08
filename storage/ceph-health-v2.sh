#!/bin/bash

source ./rcv_cep_log.sh

function notify_thru_email()
{
	echo "To:raghvendra.maloo@ril.com;swami.reddy@ril.com" > /tmp/mail.txt
	echo "Subject:$1" >> /tmp/mail.txt
	cat $2 >> /tmp/mail.txt

	curl --url "smtps://smtp.gmail.com:465" --ssl-reqd   --mail-from "rjil.notify@gmail.com" --mail-rcpt "raghvendra.maloo@ril.com"   --upload-file /tmp/mail.txt --user "rjil.notify@gmail.com:cloud@123" --insecure
	rm -f /tmp/mail.txt
}

ceph_health_timeout=30
script_sleep_min=1
latency_threshold=100 #ms

while :

do
	
	start_rcv_log /tmp/ceph.log.copy

	script_sleep_duration=`echo "$script_sleep_min""m"`
        sleep $script_sleep_duration

	stop_rcv_log

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
	fi

	WARNINGS=$(grep -v INF /tmp/ceph.log.copy)
	if [ "$WARNINGS" ]
	then
	    echo -n "Warnings in ceph.log: " >> /tmp/ceph.log.warnings
	    echo "$WARNINGS"|wc -l >> /tmp/ceph.log.warnings
	    echo "$WARNINGS" >> /tmp/ceph.log.warnings
	    echo  >> /tmp/ceph.log.warnings
	    notify_thru_email "Ceph Warnings Alert!" /tmp/ceph.log.warnings
	fi

	if [ $TIMEDOUT -eq 0 ] 
	then
		NEARFULL=`timeout $ceph_health_timeout sudo ceph -s -f json | jq .osdmap.osdmap.nearfull`

		if [ "$NEARFULL" != "false" ] 
		then
			timeout $ceph_health_timeout sudo ceph -s -f json | jq .osdmap.osdmap > /tmp/ceph.log.nearfull
			notify_thru_email "Ceph Nearfull Alert!" /tmp/ceph.log.nearfull
		fi

		NUMOSDS=`timeout $ceph_health_timeout sudo ceph osd perf -f json | jq '.osd_perf_infos | length'`
		COUNTER=0
	
		while [ $COUNTER -lt $NUMOSDS ]; do

			     LATENCY=`timeout $ceph_health_timeout sudo ceph osd perf -f json | jq .osd_perf_infos[$COUNTER].perf_stats.apply_latency_ms`

			     if [ $LATENCY -ge $latency_threshold ] 
			     then
				timeout $ceph_health_timeout sudo ceph osd perf -f json | jq .osd_perf_infos > /tmp/ceph.log.latency
				notify_thru_email "Ceph OSD Latency Alert!" /tmp/ceph.log.latency
				break
			     fi

			     let COUNTER=COUNTER+1 
		done
	fi
	
	
done

