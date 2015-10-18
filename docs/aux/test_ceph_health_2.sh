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
latency_threshold=1.0 #ms

declare -A arrLTotal
declare -A arrLOps

while :

do

	NUMNODES=`timeout $ceph_health_timeout sudo ceph osd tree -f json | jq '.nodes | length'`
	COUNTER=0
        SENDNOTIFICATION=0
	while [ $COUNTER -lt $NUMNODES ]; do

		     NODETYPE=`timeout $ceph_health_timeout sudo ceph osd tree -f json | jq .nodes[$COUNTER].type`
		     NODENAME=`timeout $ceph_health_timeout sudo ceph osd tree -f json | jq .nodes[$COUNTER].name`
		     if [ "$NODETYPE" = "\"osd\"" ] 
		     then
			 NODENAME_NOQUOTES=`echo $NODENAME | sed "s/\"//g"`
			 OSDLSUM=`sudo ceph daemon $NODENAME_NOQUOTES perf dump | jq .osd.op_latency.sum`
			 OSDLSUM=`echo $OSDLSUM \* 1000.0 | bc -l` #convert to ms
			 OSDLOPS=`sudo ceph daemon $NODENAME_NOQUOTES perf dump | jq .osd.op_latency.avgcount`
			 OSDLATENCY=`echo $OSDLSUM / $OSDLOPS | bc -l`
			 echo "$NODENAME sum $OSDLSUM ops $OSDLOPS latency $OSDLATENCY"
	                 if [ "${arrLTotal[${NODENAME}]}" != "" ]; then
	                     #compare
	                     OSDLSUMOLD=${arrLTotal[${NODENAME}]}
	                     OSDLOPSOLD=${arrLOps[${NODENAME}]}
	                     OSDLSUMDIFF=`echo $OSDLSUM - $OSDLSUMOLD + 1.0 | bc -l`
	                     OSDLOPSDIFF=`echo $OSDLOPS - $OSDLOPSOLD + 1.0 | bc -l`
	                     if [ $OSDLOPSDIFF != "0" ]; then
	                       OSDLATENCYDIFF=`echo $OSDLSUMDIFF / $OSDLOPSDIFF | bc -l`
	                       echo "diff latency $OSDLATENCYDIFF"
                               if [ $(bc <<< "$OSDLATENCYDIFF >= $latency_threshold") -eq 1 ]
			       then
				echo " Ceph OSD Latency for $NODENAME for last $script_sleep_min minutes is $OSDLATENCYDIFF ms" >> /tmp/ceph.log.latency
				SENDNOTIFICATION=1
			       fi
	                     fi
	                 fi
			 arrLTotal["$NODENAME"]=$OSDLSUM
			 arrLOps["$NODENAME"]=$OSDLOPS
			 echo ${arrLTotal[${NODENAME}]}
			 echo ${arrLOps[${NODENAME}]}
		     fi
		 
		     let COUNTER=COUNTER+1 
	done

        if [ $SENDNOTIFICATION = 1 ]; then
            notify_thru_email "Ceph OSD Latency Alert!" /tmp/ceph.log.latency
            rm -f /tmp/ceph.log.latency
        fi
        sleep 5

done
