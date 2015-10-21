#!/usr/bin/env bash

create_wait_time=5 #seconds
delete_wait_time=5 #seconds
cinder_cmd_timeout=20 #seconds

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
                curl -H "X-Auth-Token: $authtoken" "http://$get_vol_ipaddress:8776/v2/$tenant/volumes/detail" > /dev/null
		
                if [ $? -eq 0 ]; then

                        get_vol_cnt=`curl -H "X-Auth-Token: $authtoken" "http://$get_vol_ipaddress:8776/v2/$tenant/volumes/detail" | jq '.volumes | length'` > /dev/null

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

function get_snapshot_data()
{
        local get_snapshot_ipaddress=$1
        local get_vol_id=$2

        local get_snapshot_status=""
        local get_snapshot_id=""


	authtoken=`curl -s -X POST http://$get_snapshot_ipaddress:5000/v2.0/tokens -H "Content-Type: application/json" -d '{"auth": {"tenantName": "'"$OS_TENANT_NAME"'", "passwordCredentials": {"username": "'"$OS_USERNAME"'", "password": "'"$OS_PASSWORD"'"}}}' | python -m json.tool | jq .access.token.id | sed "s/\"//g"` > /dev/null

	tenant=`curl -s -X POST http://$get_snapshot_ipaddress:5000/v2.0/tokens -H "Content-Type: application/json" -d '{"auth": {"tenantName": "'"$OS_TENANT_NAME"'", "passwordCredentials": {"username": "'"$OS_USERNAME"'", "password": "'"$OS_PASSWORD"'"}}}' | python -m json.tool | jq .access.token.tenant.id | sed "s/\"//g"` > /dev/null

	#echo -e "tenant=$tenant and authtok=$authtoken"


	if [ $? -eq 0 ]; then
		curl -H "X-Auth-Token: $authtoken" "http://$get_snapshot_ipaddress:8776/v2/$tenant/snapshots/detail" > /dev/null
                if [ $? -eq 0 ]; then

                        get_snapshot_cnt=`curl -H "X-Auth-Token: $authtoken" "http://$get_snapshot_ipaddress:8776/v2/$tenant/snapshots/detail" | jq '.snapshots | length'` > /dev/null
			COUNTER=0
			while [ $COUNTER -lt $get_snapshot_cnt ]; do
			   get_cur_volid=`curl -H "X-Auth-Token: $authtoken" "http://$get_snapshot_ipaddress:8776/v2/$tenant/snapshots/detail" | jq .snapshots[$COUNTER].volume_id | sed "s/\"//g"` > /dev/null
			   get_cur_snapstatus=`curl -H "X-Auth-Token: $authtoken" "http://$get_snapshot_ipaddress:8776/v2/$tenant/snapshots/detail" | jq .snapshots[$COUNTER].status | sed "s/\"//g"` > /dev/null
			   get_cur_snapid=`curl -H "X-Auth-Token: $authtoken" "http://$get_snapshot_ipaddress:8776/v2/$tenant/snapshots/detail" | jq .snapshots[$COUNTER].id | sed "s/\"//g"` > /dev/null
                           #echo "snapshot volid $get_cur_volid status $get_cur_snapstatus id $get_cur_snapid"
			   if [ $get_cur_volid = $get_vol_id ] ; then
                                #echo "setting up snapshot status and id"
				get_snapshot_status=$get_cur_snapstatus
                                get_snapshot_id=$get_cur_snapid
                                break
			   fi
			   let COUNTER=COUNTER+1 
			done
	        fi
	fi


        local __get_snapshot_status=$3
        local __get_snapshot_id=$4
       
	eval $__get_snapshot_status=$get_snapshot_status
        eval $__get_snapshot_id=$get_snapshot_id 
}

function test_create_volume()
{
        local test_create_volname=$1
      
	timeout $cinder_cmd_timeout cinder create --display-name $test_create_volname 1

        if [ $? -eq 0 ] ; then

		sleep $create_wait_time
        fi
}

function test_delete_volume()
{
	timeout $cinder_cmd_timeout cinder delete $1
        if [ $? -eq 0 ] ; then

		sleep $delete_wait_time
        fi
}

function test_create_snapshot()
{
    	timeout $cinder_cmd_timeout cinder snapshot-create $1
        if [ $? -eq 0 ] ; then

		sleep $create_wait_time
        fi
}

function test_delete_snapshot()
{
   	timeout $cinder_cmd_timeout cinder snapshot-delete $1
        if [ $? -eq 0 ] ; then

		sleep $delete_wait_time
        fi
}

function test_availability()
{
        local test_availability_ipaddress=$1
        local __test_availability_result=$2
        
        local test_availability_result=0
        local test_availability_volname=`date -d now +Vol_%h_%d_%H_%M_%S`

	test_create_volume $test_availability_volname
        get_volume_data $test_availability_ipaddress $test_availability_volname test_availability_volstatus test_availability_volid

        #echo "volume status $test_availability_volstatus"
	if [ "$test_availability_volstatus" != "available" ]
        then
           test_availability_result=1
        else 
           #echo "volume available"
           test_create_snapshot $test_availability_volid
           get_snapshot_data $test_availability_ipaddress $test_availability_volid test_availability_snapstatus test_availability_snapid
           #echo "snapshot status $test_availability_snapstatus"
           if [ "$test_availability_snapstatus" != "available" ]
           then
                 test_availability_result=1
           else
                 test_delete_snapshot $test_availability_snapid
                 get_snapshot_data $test_availability_ipaddress $test_availability_volid test_availability_snapstatus test_availability_snapid
                 if [ "$test_availability_snapstatus" != "" ]
                 then
                     test_availability_result=1
                 fi
           fi
           test_delete_volume $test_availability_volid
           get_volume_data $test_availability_ipaddress $test_availability_volname test_availability_volstatus test_availability_volid
           if [ "$test_availability_volstatus" != "" ]
           then
                 test_availability_result=1
           fi
        fi

        eval $__test_availability_result=$test_availability_result
}
