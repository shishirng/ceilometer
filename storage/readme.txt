GOAL 

- Develop tool/script to get the used and available storage details and share with team periodically.
- Measure Average latency of the Storage Cluster.

PRE-REQUISITES

- Install Openstack, ceph with ceilometer services enabled
- Install jq tool

SCRIPTS

notify_available_storage.sh

	- Script to periodically (script_sleep_min) notify about the available storage to the specified email-ids

run_check_ceph_health.sh

	- Check periodically (script_sleep_min) the average latency of the storage cluster OSDs and notify if it goes below the specified threshold (latency_threshold).
	- Check periodically (script_sleep_min) the symptoms of storage reaching full mark (observe the nearfull flag of Ceph)
	- Check the Ceph log periodically (script_sleep_min) for any generic WARNINGs
	- Notify PM/Eng team of any issues reported by above checks

CONFIGURATION

- Set script_sleep_min in notify_available_storage.sh to set the frequency of available storage notifications
- Set script_sleep_min in run_check_ceph_health.sh to set the frequency of periodic checks for latency, warnings and nearfull status
- Set latency_threshold in run_check_ceph_health.sh to set the latency_threshold beyond which a notification email is issued to the specified ids
- Change the email aliases in notify_thru_email function of notify_available_storage.sh and run_check_ceph_health.sh scripts to address the emails appropriately

INSTRUCTIONS TO RUN

- Open a terminal
- Set $OS_USERNAME and $OS_PASSWORD env variables (source openrc admin admin)
- Run script run_check_ceph_health.sh with sudo previledge (e.g. 'sudo ./run_check_ceph_health.sh')

- Open another terminal
- Set $OS_USERNAME and $OS_PASSWORD env variables (source openrc admin admin)
- Run script notify_available_storage.sh (e.g. './notify_available_storage.sh')
