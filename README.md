# ceilometer

#install common components

sudo apt-get install git -y

sudo apt-get install python-dev libssl-dev python-pip git-core libxml2-dev libxslt-dev pkg-config libffi-dev libpq-dev libmysqlclient-dev libvirt-dev graphviz libsqlite3-dev -y

#ceph installation

git clone https://github.com/theanalyst/ceph-bootstrap

cd ceph-bootstrap

#add virtual IP address 10.0.2.15 to /etc/hosts as 10.0.2.15 <hostname>

#also add the virtual IP to current ifconfig using the following command
sudo ifconfig eth0:0 10.0.2.15

./ceph-install.sh

#devstack installation

git clone https://github.com/openstack-dev/devstack.git

cd ~/devstack

#copy https://github.com/ceph/ceph-devstack/localrc to ~/devstack/localrc

#set REMOTE_CEPH=True in the copied localrc

#replace ceph=$(uuidgen) by current ceph fsid (use command sudo ceph status)

#enable ceilometer service as suggested by http://docs.openstack.org/developer/ceilometer/install/development.html

./stack.sh

#restart nova and cinder after changes mentioned in http://docs.openstack.org/developer/ceilometer/install/development.html




