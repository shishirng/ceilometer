#!/usr/bin/env bash
# run_check_availability.sh

ipaddress=100.113.160.55

testfreq_sleep=1m

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

	
		fi
	fi
	
	sleep $testfreq_sleep
done
