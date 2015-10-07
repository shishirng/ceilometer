#!/bin/bash

function sendemail()
{
	echo "To:raghvendra.maloo@ril.com;swami.reddy@ril.com" > /tmp/mail.txt
	echo "Subject:$1" >> /tmp/mail.txt
	cat $2 >> /tmp/mail.txt

	curl --url "smtps://smtp.gmail.com:465" --ssl-reqd   --mail-from "rjil.notify@gmail.com" --mail-rcpt "raghvendra.maloo@ril.com"   --upload-file /tmp/mail.txt --user "rjil.notify@gmail.com:cloud@123" --insecure
	rm -f /tmp/mail.txt
}

ceph_health_timeout=30
script_sleep_min=30

rm -f /tmp/ceph.log.today
rm -f /tmp/ceph.log.tail
rm -f /tmp/ceph.log.warnings
rm -f /tmp/ceph.log.health

# check ceph health
HEALTH=$(timeout $ceph_health_timeout sudo ceph health)
if [ "$?" = 124 ] #timeout's exit code is 124 when the timeout is hit
then
    HEALTH="ceph health timed out (30s), potential loss of quorum!"
fi

if [ "$HEALTH" != 'HEALTH_OK' ]
then
    echo -n "Ceph is not healthy: " >> /tmp/ceph.log.health
    echo "$HEALTH" >> /tmp/ceph.log.health
    echo >> /tmp/ceph.log.health
    sendmail "Ceph Health Alert!" /tmp/ceph.log.health
fi

# get logs for specified minutes
awk -vDATE=`date +%Y-%m-%d` ' { if ($1 >= DATE) print $0}' /var/log/ceph/ceph.log > /tmp/ceph.log.today
awk -vTIME=`date -d "now - $script_sleep_min minutes" +%H:%M:%S` ' { if ($2 > TIME) print $0}' /tmp/ceph.log.today > /tmp/ceph.log.tail

WARNINGS=$(grep -v INF /tmp/ceph.log.tail)
if [ "$WARNINGS" ]
then
    echo -n "Warnings in ceph.log: " >> /tmp/ceph.log.warnings
    echo "$WARNINGS"|wc -l >> /tmp/ceph.log.warnings
    echo "$WARNINGS" >> /tmp/ceph.log.warnings
    echo  >> /tmp/ceph.log.warnings
    sendemail "Ceph Warnings Alert!" /tmp/ceph.log.warnings
fi

