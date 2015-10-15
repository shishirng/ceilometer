- Make sure jq is installed
- Ensure $OS_USERNAME and $OS_PASSWORD env variables are set properly (i.e. source openrc)
- Apply instrumentation/create_vol_inst.path to Cinder Python code
- Restart Cinder Scheduler Service
- Configure chkfreq in run_check_vol_creation.sh
- Start ./run_check_vol_creation.sh

Note: to check volume creation pass rate other than specified chkfreq use script ./query_vol_creation.sh
