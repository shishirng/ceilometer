#!/bin/bash

function notify_thru_email()
{
	echo "To:raghvendra.maloo@ril.com;swami.reddy@ril.com" > /tmp/mail.txt
	echo "Subject:$1" >> /tmp/mail.txt
	cat $2 >> /tmp/mail.txt

	curl --url "smtps://smtp.gmail.com:465" --ssl-reqd   --mail-from "rjil.notify@gmail.com" --mail-rcpt "raghvendra.maloo@ril.com"   --upload-file /tmp/mail.txt --user "rjil.notify@gmail.com:cloud@123" --insecure
	rm -f /tmp/mail.txt
}

ceph_health_timeout=30
script_sleep_min=30

while :

do

	
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
	    echo -n "Ceph Storage Info not available : Ceph is not healthy - " >> /tmp/ceph.log.health
	    echo "$HEALTH" >> /tmp/ceph.log.health
	    echo >> /tmp/ceph.log.health
	    notify_thru_email "Ceph Storage Info not available!" /tmp/ceph.log.health
	fi

	if [ $TIMEDOUT -eq 0 ] 
	then
		BYTESTOTAL=`timeout $ceph_health_timeout sudo ceph status -f json | jq .pgmap.bytes_total`
                BYTESAVAIL=`timeout $ceph_health_timeout sudo ceph status -f json | jq .pgmap.bytes_avail`
                BYTESUSED=`timeout $ceph_health_timeout sudo ceph status -f json | jq .pgmap.bytes_used`
		perc=$(( $BYTESAVAIL * 100 / $BYTESTOTAL )) #check for precision in case of TB
		echo "Ceph Storage (Bytes) Used $BYTESUSED, Available $BYTESAVAIL / Total $BYTESTOTAL" > /tmp/ceph.log.storage
		notify_thru_email "Ceph Available Storage $perc%" /tmp/ceph.log.storage
	fi
	
	script_sleep_duration=`echo "$script_sleep_min""m"`
        sleep $script_sleep_duration


	
done

