#!/usr/bin/env bash
# run_check_availability.sh

failed=0
passed=0

testrun_timeout=2m
testfreq_sleep=1m
samplecrt_timeout=1m

function recover_evt {

	 while [  $passed -gt 0 ]; do
             timeout $samplecrt_timeout ceilometer sample-create --resource-id 0 --meter-name availability.status.event --meter-type gauge --meter-unit N/A --sample-volume 1 --direct True
             let passed=passed-1 
         done

	while [  $failed -gt 0 ]; do
             timeout $samplecrt_timeout ceilometer sample-create --resource-id 0 --meter-name availability.status.event --meter-type gauge --meter-unit N/A --sample-volume 0 --direct True
             let failed=failed-1 
         done

}

while :

do

	rand=$(( ( RANDOM % 100 )  + 1 ))

	echo "rand value is $rand"

	if [ $rand -gt 60 ]; then
	    
	   timeout $testrun_timeout ./run_tempest.sh tempest.api.failvol -N

	else

	   timeout $testrun_timeout ./run_tempest.sh tempest.api.passvol -N

	fi

        if [ $? -eq 0 ]; then
	
	    timeout $samplecrt_timeout ceilometer sample-create --resource-id 0 --meter-name availability.status.event --meter-type gauge --meter-unit N/A --sample-volume 1 --direct True

	    if [ $? -ne 0 ]; then
	    	
		let 'passed += 1'
	    else
		recover_evt
	    fi

	else
	
	    timeout $samplecrt_timeout ceilometer sample-create --resource-id 0 --meter-name availability.status.event --meter-type gauge --meter-unit N/A --sample-volume 0 --direct True

	    if [ $? -ne 0 ]; then
	    	
		let 'failed += 1'
	    else
		recover_evt
	    fi

	   compute_avg availability.status.event 0 0 1 0 0 0  avg_returned_value ttc_returned_value
			
	   echo "To:raghvendra.maloo@ril.com;swami.reddy@ril.com" > /tmp/mail.txt
	   echo "Subject:Availability Test Failure" >> /tmp/mail.txt
	   echo "Availability Drop ALERT!! Availability for last one hour is $avg_returned_value%" >> /tmp/mail.txt

	   curl --url "smtps://smtp.gmail.com:465" --ssl-reqd   --mail-from "rjil.notify@gmail.com" --mail-rcpt "raghvendra.maloo@ril.com"   --upload-file /tmp/mail.txt --user "rjil.notify@gmail.com:cloud@123" --insecure
	
	fi

	sleep $testfreq_sleep

done
