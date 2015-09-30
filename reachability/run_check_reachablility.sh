#!/usr/bin/env bash
# run_check_availability.sh

source ./query_sample_avg.sh

function usage {
  echo "Usage: run_check_reachability <ipaddress>"
  echo ""
}

if  [ $# -lt 1 ] ; then

	usage
	exit 1
fi


ipaddress=$1

testfreq_sleep=1m

echo -e "ipaddress=$ipaddress"

while :

do

        authtoken=`curl -s -X POST http://$ipaddress:5000/v2.0/tokens -H "Content-Type: application/json" -d '{"auth": {"tenantName": "'"$OS_TENANT_NAME"'", "passwordCredentials": {"username": "'"$OS_USERNAME"'", "password": "'"$OS_PASSWORD"'"}}}' | python -m json.tool | jq .access.token.id | sed "s/\"//g"` 

tenant=`curl -s -X POST http://$ipaddress:5000/v2.0/tokens -H "Content-Type: application/json" -d '{"auth": {"tenantName": "'"$OS_TENANT_NAME"'", "passwordCredentials": {"username": "'"$OS_USERNAME"'", "password": "'"$OS_PASSWORD"'"}}}' | python -m json.tool | jq .access.token.tenant.id | sed "s/\"//g"`

	echo -e "tenant=$tenant and authtok=$authtoken"


	if [ $? -eq 0 ]; then

		#curl -H "X-Auth-Token: $authtoken" "$cinderendpoint/volumes" | python -m json.tool > /dev/null
		curl -H "X-Auth-Token: $authtoken" "http://$ipaddress:8776/v2/$tenant/volumes" | python -m json.tool > /dev/null

		if [ $? -eq 0 ]; then
	
		    curl -g -i -X 'POST' "http://$ipaddress:8777/v2/meters/reachability.status.event?direct=True" -H 'User-Agent: ceilometerclient.openstack.common.apiclient' -H 'Content-Type: application/json' -H "X-Auth-Token: $authtoken" -d '[{"counter_type": "gauge", "counter_name": "reachability.status.event", "resource_id": "0", "counter_unit": "N/A", "counter_volume": "1.0"}]' > /dev/null


		else
	
		    curl -g -i -X 'POST' "http://$ipaddress:8777/v2/meters/reachability.status.event?direct=True" -H 'User-Agent: ceilometerclient.openstack.common.apiclient' -H 'Content-Type: application/json' -H "X-Auth-Token: $authtoken" -d '[{"counter_type": "gauge", "counter_name": "reachability.status.event", "resource_id": "0", "counter_unit": "N/A", "counter_volume": "0.0"}]'

		    compute_avg reachability.status.event 0 0 1 0 0 0  avg_returned_value ttc_returned_value
			
		    echo "To:raghvendra.maloo@ril.com;swami.reddy@ril.com" > /tmp/mail.txt
		    echo "Subject:Reachability Test Failure" >> /tmp/mail.txt
		    echo "Reachability Drop ALERT!! Reachability for last one hour is $avg_returned_value%" >> /tmp/mail.txt

		    curl --url "smtps://smtp.gmail.com:465" --ssl-reqd   --mail-from "rjil.notify@gmail.com" --mail-rcpt "raghvendra.maloo@ril.com"   --upload-file /tmp/mail.txt --user "rjil.notify@gmail.com:cloud@123" --insecure

		    rm -f /tmp/mail.txt

	
		fi
	fi
	
	sleep $testfreq_sleep
done
