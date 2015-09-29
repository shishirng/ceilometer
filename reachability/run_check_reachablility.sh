#!/usr/bin/env bash
# run_check_availability.sh

while :

do

        curl -s -X POST http://100.113.160.55:5000/v2.0/tokens -H "Content-Type: application/json" -d '{"auth": {"tenantName": "'"$OS_TENANT_NAME"'", "passwordCredentials": {"username": "'"$OS_USERNAME"'", "password": "'"$OS_PASSWORD"'"}}}' | python -m json.tool

	curl -H 'X-Auth-Token: 34562e4889ff4897bb86f0f4268af940' "http://100.113.160.55:8776/v2/c2e7ea532e0442b991d4db3097bbabe3/volumes" | python -m json.tool

	if [ $? -eq 0 ]; then
	
	    curl -g -i -X 'POST' 'http://100.113.160.55:8777/v2/meters/reachability.status.event?direct=True' -H 'User-Agent: ceilometerclient.openstack.common.apiclient' -H 'Content-Type: application/json' -H 'X-Auth-Token: 34562e4889ff4897bb86f0f4268af940' -d '[{"counter_type": "gauge", "counter_name": "reachability.status.event", "resource_id": "0", "counter_unit": "N/A", "counter_volume": "1.0"}]'


	else
	
	    curl -g -i -X 'POST' 'http://100.113.160.55:8777/v2/meters/reachability.status.event?direct=True' -H 'User-Agent: ceilometerclient.openstack.common.apiclient' -H 'Content-Type: application/json' -H 'X-Auth-Token: 34562e4889ff4897bb86f0f4268af940' -d '[{"counter_type": "gauge", "counter_name": "reachability.status.event", "resource_id": "0", "counter_unit": "N/A", "counter_volume": "0.0"}]'

	
	fi
	
	sleep 2m

done
