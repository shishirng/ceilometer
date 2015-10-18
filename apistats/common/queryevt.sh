#!/usr/bin/env bash

#usage : comute_avg <event> <seconds> <minutes> <hours> <days> <weeks> <months> <avg> <ttc>

function compute_evtcnt()
{
	local seconds=$2
	local minutes=$3
	local hours=$4
	local days=$5
	local weeks=$6
	local months=$7
	
	local ttc=`date -u --iso-8601=seconds -d "now - $months months - $weeks weeks - $days days - $hours hours - $minutes minutes - $seconds seconds"`
	local ttc_to_show=`date +'%x %T' -d $ttc`

	cnt=`ceilometer event-list --no-trait --query "event_type=$1; start_timestamp>=$ttc" | wc -l`
	cnt=$((cnt - 4))

	local __avg_output=$8
	local __ttc_output=$9

	eval $__avg_output="$cnt"
	eval $__ttc_output="'$ttc_to_show'"


}
