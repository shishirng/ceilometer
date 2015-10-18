GOAL 

availability check, query and notifications

PRE-REQUISITES

- Make sure jq is installed
- Ensure $OS_USERNAME and $OS_PASSWORD env variables are set properly (i.e. source openrc)

SCRIPTS

run_check_availability.sh - continuosly loops and check the availability of the cluster and notify about failures
query_availability.sh - manual query for availability for the specified window of time in terms of minutes, seconds, days, months etc.


CONFIGURATION

set time freq
set percentage threshold for notifications

INSTRUCTIONS TO RUN

- run script run_check_availability 
- on another terminal you can check availability percentage for a require time window using query_availability.sh
