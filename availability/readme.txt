GOAL 

Availability SLA with 99.9%

Develop tool/script to continuously check the SBS service request's responses in the past 5 min. and calculate the availability SLA. Raise an alert if the metrics < 99.9%.

PRE-REQUISITES

- Install Openstack, ceph with ceilometer services enabled
- Install jq tool

SCRIPTS

run_check_availability.sh 

	- Continuosly runs the volume/snapshot creation testcases with the specified interval (testfreq_sleep) [Checking the availability]
 	- Logs the testcase run results with the timestamp into the ceilometer
	- On testcase failures computes the availabilty for last one hour and if this is less the specified SLA (a_threshold) it notifies the PM/Eng aliases thru email

        echo "Usage: run_check_availability <endpoint IP address>"

query_availability.sh

	- The script allows users to query the availability percentage for the specified window of time in terms of seconds, minutes, days, weeks, months

	  echo "Usage: $0 [OPTION]..."
	  echo "Query Availability"
	  echo ""
	  echo "  -S, --seconds        	Availability during these many seconds before to now"
	  echo "  -X, --minutes        	Availability during these many minutes before to now"
	  echo "  -H, --hours        	Availability during these many hours before to now"
	  echo "  -D, --days        	Availability during these many days before to now"
	  echo "  -W, --weeks        	Availability during these many weeks before to now"
	  echo "  -M, --months        	Availability during these many months before to now"

CONFIGURATION

- Set testfreq_sleep var in runc_check_availability.sh script to configure the frequency of running the availability testcases.
- Set a_threshold var in run_check_availability.sh script to configure the SLA availability percentage threshold requirement
- Change --mail-rcpt to the required PM/Eng aliases for SLA violation and testcase failure notifications

INSTRUCTIONS TO RUN

- Open a terminal
- Set $OS_USERNAME and $OS_PASSWORD env variables (source openrc admin admin)
- run script run_check_availability (e.g. './run_check_availability.sh 10.0.2.15')

To manually query the current Availaiblity pecentage 

- Open a terminal
- Set $OS_USERNAME and $OS_PASSWORD env variables (source openrc admin admin)
- run script query_availability.sh with the required time window (e.g. for last 10 minutes run './query_availability.sh -X 10')

