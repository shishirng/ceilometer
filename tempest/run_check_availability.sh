#!/usr/bin/env bash
# run_check_availability.sh

while :

do

	rand=$(( ( RANDOM % 100 )  + 1 ))

	echo "rand value is $rand"

	if [ $rand -gt 80 ]; then
	    
	   ./run_tempest.sh tempest.api.failvol -N

	else

	   ./run_tempest.sh tempest.api.passvol -N

	fi

        if [ $? -eq 0 ]; then
	
	    ceilometer sample-create --resource-id 0 --meter-name availability.status.passed --meter-type gauge --meter-unit N/A --sample-volume 0 --direct True

	else
	
	    ceilometer sample-create --resource-id 0 --meter-name availability.status.failed --meter-type gauge --meter-unit N/A --sample-volume 0 --direct True
	
	fi

	sleep 2m

done
