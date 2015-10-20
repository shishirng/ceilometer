GOAL 

Reachability of SBS endpoint

Develop tool/script to continuously check the SBS service endpoint reachability using 5 min. window. Raise an alert if the metrics < 99.9%.

PRE-REQUISITES

- Install Openstack, ceph with ceilometer services enabled
- Install jq tool

SCRIPTS

run_check_reachability.sh 

	- Continuosly runs and checks the endpoint access after every specified interval (testfreq_sleep) using the Openstack RESTFUL APIs [Checking the Reachability]
 	- Logs the reachability results with the timestamp into the ceilometer
	- On reachability broken, it computes the reachability percentage for last one hour and if this is less the specified SLA (r_threshold) it notifies the PM/Eng aliases thru email

	echo "Usage: run_check_reachability <endpoint IP address>"

query_reachability.sh

	- The script allows users to query the reachability percentage for the specified window of time in terms of seconds, minutes, days, weeks, months

	  echo "Usage: $0 [OPTION]..."
	  echo "Query Reachability"
	  echo ""
	  echo "  -S, --seconds        	Availability during these many seconds before to now"
	  echo "  -X, --minutes        	Availability during these many minutes before to now"
	  echo "  -H, --hours        	Availability during these many hours before to now"
	  echo "  -D, --days        	Availability during these many days before to now"
	  echo "  -W, --weeks        	Availability during these many weeks before to now"
	  echo "  -M, --months        	Availability during these many months before to now"

CONFIGURATION

- Set testfreq_sleep var in runc_check_reachability.sh script to configure the frequency of running the reachability testcases.
- Set r_threshold var in run_check_reachability.sh script to configure the SLA reachability percentage threshold requirement
- Change --mail-rcpt to the required PM/Eng aliases for SLA violation and reachability failure notifications

INSTRUCTIONS TO RUN

- Open a terminal
- Set $OS_USERNAME and $OS_PASSWORD env variables (source openrc admin admin)
- run script run_check_reachability (e.g. './run_check_availability.sh 10.0.2.15')

To manually query the current Availaiblity pecentage 

- Open a terminal
- Set $OS_USERNAME and $OS_PASSWORD env variables (source openrc admin admin)
- run script query_reachability.sh with the required time window (e.g. for last 10 minutes run './query_reachability.sh -X 10')

