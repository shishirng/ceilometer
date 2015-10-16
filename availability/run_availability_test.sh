#!/usr/bin/env bash
# run_check_availability.sh

ipaddress=localhost
testfreq_sleep=1m

create_wait_time=30 #seconds

function test_create_volume()
{

        local __test_result=$1
        eval $__test_result="1"

	create_volname=`date -d now +Vol_%h_%d_%H_%M_%S`
        
	cinder create --display-name $create_volname 1

        sleep $create_wait_time

        authtoken=`curl -s -X POST http://$ipaddress:5000/v2.0/tokens -H "Content-Type: application/json" -d '{"auth": {"tenantName": "'"$OS_TENANT_NAME"'", "passwordCredentials": {"username": "'"$OS_USERNAME"'", "password": "'"$OS_PASSWORD"'"}}}' | python -m json.tool | jq .access.token.id | sed "s/\"//g"` 

tenant=`curl -s -X POST http://$ipaddress:5000/v2.0/tokens -H "Content-Type: application/json" -d '{"auth": {"tenantName": "'"$OS_TENANT_NAME"'", "passwordCredentials": {"username": "'"$OS_USERNAME"'", "password": "'"$OS_PASSWORD"'"}}}' | python -m json.tool | jq .access.token.tenant.id | sed "s/\"//g"`

	echo -e "tenant=$tenant and authtok=$authtoken"


	if [ $? -eq 0 ]; then

		#curl -H "X-Auth-Token: $authtoken" "$cinderendpoint/volumes" | python -m json.tool > /dev/null
		volcnt=`curl -H "X-Auth-Token: $authtoken" "http://$ipaddress:8776/v2/$tenant/volumes/detail" | jq '.volumes | length'`
                COUNTER=0
		while [ $COUNTER -lt $volcnt ]; do
                   volname=`curl -H "X-Auth-Token: $authtoken" "http://$ipaddress:8776/v2/$tenant/volumes/detail" | jq .volumes[$COUNTER].name`
                   volstatus=`curl -H "X-Auth-Token: $authtoken" "http://$ipaddress:8776/v2/$tenant/volumes/detail" | jq .volumes[$COUNTER].status`
                   volid=`curl -H "X-Auth-Token: $authtoken" "http://$ipaddress:8776/v2/$tenant/volumes/detail" | jq .volumes[$COUNTER].id | sed "s/\"//g"`
                   echo "volname $volname and volstatus $volstatus and volume id $volid"
                   if [ $volname = "\"$create_volname\"" ] ; then
			if [ $volstatus = "\"available\"" ] ; then
                            echo "passed"
                            eval $__test_result=0
                            cinder delete $volid
                        fi
                   fi
                   let COUNTER=COUNTER+1 
		done
                
	fi
}


echo -e "ipaddress=$ipaddress"

while :

do
        test_create_volume test_result

	if [ $test_result -eq 0 ]
        then
           echo "success"
        else
           echo "failure"
        fi
	
	sleep $testfreq_sleep
done
