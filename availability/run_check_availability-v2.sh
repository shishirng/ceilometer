#!/usr/bin/env bash
# run_check_availability.sh

source ./query_sample_avg.sh
source ./run_availability_test.sh

function usage {
  echo "Usage: run_check_availability <ipaddress>"
  echo ""
}

if  [ $# -lt 1 ] ; then

	usage
	exit 1
fi


g_ipaddress=$1

failed=0
passed=0

testrun_timeout=2m
testfreq_sleep=1m
samplecrt_timeout=1m
a_threshold=99.9

function recover_evt {

	 while [  $passed -gt 0 ]; do
             timeout $samplecrt_timeout ceilometer sample-create --resource-id 0 --meter-name availability.status.event --meter-type gauge --meter-unit N/A --sample-volume 1
             let passed=passed-1 
         done

	while [  $failed -gt 0 ]; do
             timeout $samplecrt_timeout ceilometer sample-create --resource-id 0 --meter-name availability.status.event --meter-type gauge --meter-unit N/A --sample-volume 0
             let failed=failed-1 
         done

}

while :

do

	test_create_volume $g_ipaddress test_result

        if [ $test_result -eq 0 ]; then
	
	    timeout $samplecrt_timeout ceilometer sample-create --resource-id 0 --meter-name availability.status.event --meter-type gauge --meter-unit N/A --sample-volume 1

	    if [ $? -ne 0 ]; then
	    	
		let 'passed += 1'
	    else
		recover_evt
	    fi

	else
	
	    timeout $samplecrt_timeout ceilometer sample-create --resource-id 0 --meter-name availability.status.event --meter-type gauge --meter-unit N/A --sample-volume 0

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
           if [ $(bc <<< "$avg_returned_value <= $a_threshold") -eq 1 ]; then
           	#notify PMs
		#echo "To:Ravikanth.Maddikonda@ril.com" > /tmp/mail.txt
                echo "To:raghvendra.maloo@ril.com;swami.reddy@ril.com" > /tmp/mail.txt
		echo "Subject:Availability Below Threshold!" >> /tmp/mail.txt
		echo "Availability Drop ALERT!! Availability for last one hour is $avg_returned_value%" >> /tmp/mail.txt

		#curl --url "smtps://smtp.gmail.com:465" --ssl-reqd   --mail-from "rjil.notify@gmail.com" --mail-rcpt "Ravikanth.Maddikonda@ril.com"   --upload-file /tmp/mail.txt --user "rjil.notify@gmail.com:cloud@123" --insecure
                curl --url "smtps://smtp.gmail.com:465" --ssl-reqd   --mail-from "rjil.notify@gmail.com" --mail-rcpt "raghvendra.maloo@ril.com"   --upload-file /tmp/mail.txt --user "rjil.notify@gmail.com:cloud@123" --insecure
           fi
	
	fi

	sleep $testfreq_sleep

done
