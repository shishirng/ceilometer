#!/bin/bash

function start_rcv_log()
{
	sudo rm -f $1
	sudo ceph -w > $1&
}

function stop_rcv_log()
{
	ps aux | grep "ceph -w" | grep -v grep > /tmp/ceph.w.cmd
	while read line; 
	do 
		PROCID=`echo "$line" | awk '{ print $2 }'`; 
		sudo kill -9 $PROCID

	done < /tmp/ceph.w.cmd
}

