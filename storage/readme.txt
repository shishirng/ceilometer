GOAL 

health check of ceph including latency, warnings, nearfull status 
periodic notification for available storage

PRE-REQUISITES

- Make sure jq is installed
- Ensure $OS_USERNAME and $OS_PASSWORD env variables are set properly (i.e. source openrc)

SCRIPTS

notify_available_storage.sh - script to periodically notify about the available storage
run_check_ceph_health.sh - script to check the ceph health, osd latencies, log warning and nearfull flag status

CONFIGURATION

set time freq
set percentage threshold for notifications

INSTRUCTIONS TO RUN

-run the run_check_ceph_health.sh with sudo previledge e.g. >> sudo ./run_check_ceph_health.sh
-run notify_available_storage.sh in another terminal
