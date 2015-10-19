#!/usr/bin/env bash

create_wait_time=5 #seconds
create_cmd_timeout=20 #seconds

function get_volume_data()
{
        local get_vol_ipaddress=$1
        local get_vol_name=$2

        local get_vol_status=""
        local get_vol_id=""


	authtoken=`curl -s -X POST http://$get_vol_ipaddress:5000/v2.0/tokens -H "Content-Type: application/json" -d '{"auth": {"tenantName": "'"$OS_TENANT_NAME"'", "passwordCredentials": {"username": "'"$OS_USERNAME"'", "password": "'"$OS_PASSWORD"'"}}}' | python -m json.tool | jq .access.token.id | sed "s/\"//g"` > /dev/null

	tenant=`curl -s -X POST http://$get_vol_ipaddress:5000/v2.0/tokens -H "Content-Type: application/json" -d '{"auth": {"tenantName": "'"$OS_TENANT_NAME"'", "passwordCredentials": {"username": "'"$OS_USERNAME"'", "password": "'"$OS_PASSWORD"'"}}}' | python -m json.tool | jq .access.token.tenant.id | sed "s/\"//g"` > /dev/null

	#echo -e "tenant=$tenant and authtok=$authtoken"


	if [ $? -eq 0 ]; then
		get_vol_cnt=`curl -H "X-Auth-Token: $authtoken" "http://$get_vol_ipaddress:8776/v2/$tenant/volumes/detail" | jq '.volumes | length'` > /dev/null
                if [ $? -eq 0 ]; then

			COUNTER=0
			while [ $COUNTER -lt $get_vol_cnt ]; do
			   get_cur_volname=`curl -H "X-Auth-Token: $authtoken" "http://$get_vol_ipaddress:8776/v2/$tenant/volumes/detail" | jq .volumes[$COUNTER].name | sed "s/\"//g"` > /dev/null
			   get_cur_volstatus=`curl -H "X-Auth-Token: $authtoken" "http://$get_vol_ipaddress:8776/v2/$tenant/volumes/detail" | jq .volumes[$COUNTER].status | sed "s/\"//g"` > /dev/null
			   get_cur_volid=`curl -H "X-Auth-Token: $authtoken" "http://$get_vol_ipaddress:8776/v2/$tenant/volumes/detail" | jq .volumes[$COUNTER].id | sed "s/\"//g"` > /dev/null
                           #echo "volume name $get_cur_volname status $get_cur_volstatus id $get_cur_volid"
			   if [ $get_cur_volname = $get_vol_name ] ; then
                                #echo "setting up vol status and id"
				get_vol_status=$get_cur_volstatus
                                get_vol_id=$get_cur_volid
                                break
			   fi
			   let COUNTER=COUNTER+1 
			done
	        fi
	fi


        local __get_vol_status=$3
        local __get_vol_id=$4
       
	eval $__get_vol_status=$get_vol_status
        eval $__get_vol_id=$get_vol_id 
}

function test_create_volume()
{
        local test_create_ipaddress=$1
        local test_create_volname=$2
        
        local test_create_result="1"

	timeout $create_cmd_timeout cinder create --display-name $test_create_volname 1

        if [ $? -eq 0 ] ; then

		sleep $create_wait_time
		get_volume_data $test_create_ipaddress $test_create_volname test_create_volstatus test_create_volid
                #echo "volume status $test_create_volstatus"
		if [ $test_create_volstatus = "available" ]
                then
                   #echo "volume available"
                   test_create_result=0
                fi
        fi

        local __test_create_result=$3
        eval $__test_create_result=$test_create_result

}

function test_availability()
{
        local __test_availability_result=$2

        local test_availability_result
        local create_volname=`date -d now +Vol_%h_%d_%H_%M_%S`
	test_create_volume $1 $create_volname test_availability_result
        if [ $test_availability_result -eq 0 ]; then
           cinder delete $create_volname
        fi
        eval $__test_availability_result=$test_availability_result
}
