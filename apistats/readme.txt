GOAL 

Collect statistics of volume creation and snapshot creation customer APIs. Auto notify in case the pass rate is below given threshold.

PRE-REQUISITES

- Make sure jq is installed
- Ensure $OS_USERNAME and $OS_PASSWORD env variables are set properly (i.e. source openrc)
- Apply instrumentation/create_vol_snapshot.patch
- Restart Cinder Volume, Scheduler and API services

SCRIPTS

run_check_vol_snapshot_creation.sh
query_vol_creation.sh
query_snapshot_creation.sh

CONFIGURATION

set time freq
set percentage threshold for notifications

INSTRUCTIONS TO RUN

- Start ./run_check_vol_snapshot_creation.sh

To check volume creation pass rate for any time window use ./query_vol_creation.sh
To check snapshot creation pass rate for any time window use  ./query_snapshot_creation.sh
