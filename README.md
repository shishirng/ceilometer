This project implements the monitoring system for Openstack - Block Storage with the following Features:

Availability SLA with 99.9%

	Develop tool/script to continuously check the SBS service request's responses in the past 5 min. and calculate the availability SLA. Raise an alert if the metrics < 99.9%.

        Implementation : ./availability/readme.txt

Reachability of SBS endpoint

	Develop tool/script to continuously check the SBS service endpoint reachability using 5 min. window. Raise an alert if the metrics < 99.9%.
        
        Implementation : ./reachability/readme.txt

Storage Cluster Health monitoring

	Develop tool/script to get the used and available storage details and share with team periodically.

	Measure Average latency of the Storage Cluster.

        Implementation : ./storage/readme.txt

Customers statistics and checks for not able to create volumes/snapshots within quota limits.

	Collect statistics of volume creation and snapshot creation customer APIs. Auto notify in case the pass rate is below given threshold.

        Implementation : ./apistats/readme.txt

INSTRUCTIONS TO SETUP

	Install Openstack with Ceph and ceilometer services enabled - follow instructions in ./docs/readme.txt
        
        Follow instructions of feature specific readme.txt


