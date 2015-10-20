GOAL 

More than 5% customers complain not able to create volumes/snapshots within quota limits.
Collect statistics of volume creation and snapshot creation customer APIs. Auto notify in case the pass rate is below given threshold.

PRE-REQUISITES

- Install Openstack, ceph with ceilometer services enabled
- Install jq tool
- Apply ../instrumentation/create_vol_snapshot.patch
- Restart Cinder Volume, Scheduler and API services

SCRIPTS

run_check_vol_snapshot_creation.sh

- This script periodically (chkfreq) checks the current volume and snapshot creation pass rate for last one hour
- If the volume or snapshot creation pass rate falls below the given threshold (vc_threshold) then it notify through email to the given aliases

query_vol_creation.sh

- The script allows users to query the volume creation pass percentage for the specified window of time in terms of seconds, minutes, days, weeks, months

	  echo "Usage: $0 [OPTION]..."
	  echo "Query Snapshot Creation"
	  echo ""
	  echo "  -S, --seconds        	Availability during these many seconds before to now"
	  echo "  -X, --minutes        	Availability during these many minutes before to now"
	  echo "  -H, --hours        	Availability during these many hours before to now"
	  echo "  -D, --days        	Availability during these many days before to now"
	  echo "  -W, --weeks        	Availability during these many weeks before to now"
	  echo "  -M, --months        	Availability during these many months before to now"

query_snapshot_creation.sh

- The script allows users to query the snapshot creation pass percentage for the specified window of time in terms of seconds, minutes, days, weeks, months

	  echo "Usage: $0 [OPTION]..."
	  echo "Query Snapshot Creation"
	  echo ""
	  echo "  -S, --seconds        	Availability during these many seconds before to now"
	  echo "  -X, --minutes        	Availability during these many minutes before to now"
	  echo "  -H, --hours        	Availability during these many hours before to now"
	  echo "  -D, --days        	Availability during these many days before to now"
	  echo "  -W, --weeks        	Availability during these many weeks before to now"
	  echo "  -M, --months        	Availability during these many months before to now"

CONFIGURATION

- Set chkfreq parameter in run_check_vol_snapshot_creation.sh to the require time frequecy the volume and snapshot creation checks should run
- Set the vc_threshold parameter in run_check_vol_snapshot_creation.sh to the required percentage below which notification will be issued.
- Change the email aliases in run_check_vol_snapshot_creation.sh scripts to address the emails appropriately

INSTRUCTIONS TO RUN

- Open a terminal
- Set $OS_USERNAME and $OS_PASSWORD env variables (source openrc admin admin)
- run script ./run_check_vol_snapshot_creation.sh

To check volume creation pass rate for any time window 

- Open a terminal
- Set $OS_USERNAME and $OS_PASSWORD env variables (source openrc admin admin)
- run script ./query_vol_creation.sh with the required time window (e.g. for last 10 minutes run './query_vol_creation.sh -X 10')

To check snapshot creation pass rate for any time window

- Open a terminal
- Set $OS_USERNAME and $OS_PASSWORD env variables (source openrc admin admin)
- run script ./query_snapshot_creation.sh with the required time window (e.g. for last 10 minutes run './query_snapshot_creation.sh -X 10')
