#!/usr/bin/env bash
# query_availability.sh

#ceilometer statistics --meter availability.status.event --query 'timestamp>=2015-09-11T04:24:28;timestamp<=2015-09-14T19:27:56' > /tmp/stats
ceilometer statistics --meter availability.status.event --query 'timestamp>=2015-09-11T04:24:28' > /tmp/stats
a=1
while read line; 
do 
	if [ $((a)) -eq 4 ]; then
         	
		b=1
		for word in $line; do 
			
			if [ $((b)) -eq 12 ]; then
				echo -e "             ----------------------------------"
				echo -e "                Availability : $word%"
				echo -e "             ----------------------------------"
                        fi
                        let "b += 1"
		done
	fi
        let "a += 1"

done < /tmp/stats

rm -f /tmp/stats
