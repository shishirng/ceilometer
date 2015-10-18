#!/usr/bin/env bash

#usage : comute_avg <event> <seconds> <minutes> <hours> <days> <weeks> <months> <avg> <ttc>

function compute_avg()
{
	local seconds=$2
	local minutes=$3
	local hours=$4
	local days=$5
	local weeks=$6
	local months=$7
	
	local ttc=`date -u --iso-8601=seconds -d "now - $months months - $weeks weeks - $days days - $hours hours - $minutes minutes - $seconds seconds"`
	local ttc_to_show=`date +'%x %T' -d $ttc`

	ceilometer statistics --meter $1 --query "timestamp>=$ttc" > /tmp/stats

	local __avg_output=$8
	local __ttc_output=$9

	eval $__avg_output="[n/a]"
	eval $__ttc_output="'$ttc_to_show'"

	a=1
	while read line; 
	do 
		if [ $((a)) -eq 4 ]; then
		 	
			b=1
			for word in $line; do 
			
				if [ $((b)) -eq 12 ]; then
					c=`echo $word \* 100.0 | bc -l`
					eval $__avg_output="'$c'"
		                fi
		                let "b += 1"
			done
		fi
		let "a += 1"

	done < /tmp/stats

	rm -f /tmp/stats
}
