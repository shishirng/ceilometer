#!/bin/bash

function start_rcv_log()
{
	sudo ceph -w > /tmp/ceph.log.copy&
}

function stop_rcv_log()
{
	ps aux | grep "ceph -w" | grep -v grep > /tmp/ceph.w.cmd
	while read line; 
	do 
		PROCID=`echo "$line" | awk '{ print $2 }'`; 
		sudo kill -9 $PROCID

	done < /tmp/ceph.w.cmd
	#sudo rm -f /tmp/ceph.log.copy
}

start_rcv_log
sleep 60
stop_rcv_log
