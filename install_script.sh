#!/bin/bash
# author: 	Nicolas Louis <nicolas.siuol@gmail.com>
# version: 	20160322
# description: 	This script try to automated an installation of elk and plaso on a clean debian installation.
# todo:		1 - Be sure that all action in the for loop are mendatory, the installation could be fastest (delete the make commande ?)
#		2 - Find a way to get the lastest version of elk automatically
#		3 - Add default configuration files for all softwares
#		4 - Handle the potential error
#		5 - Do a user friendly output

elasticsearch_download_link="https://download.elasticsearch.org/elasticsearch/release/org/elasticsearch/distribution/deb/elasticsearch/2.2.1/elasticsearch-2.2.1.deb"
kibana_download_link="https://download.elastic.co/kibana/kibana/kibana-4.4.2-linux-x64.tar.gz"
logstash_download_link="https://download.elastic.co/logstash/logstash/packages/debian/logstash_2.2.2-1_all.deb"

install_elasticsearch()
{
	# check if elasticsearch is install
	if ! dpkg -s elasticsearch | grep "Status"; then
		wget $elasticsearch_download_link
		dpkg -i ./elastic*.deb
	fi

	# configrue elasticsearch
	# make it start at boot
	update-rc.d elasticsearch defaults 95 10
	# start the service
	/etc/init.d/elasticsearch restart

	# install plugins
	if /usr/share/elasticsearch/bin/plugin | grep "hq"; then
		/usr/share/elasticsearch/bin/plugin install royrusso/elasticsearch-HQ
	fi
}

install_kibana()
{
	apt-get -qq install apache2
	if [ -e /var/www/html/index.html ]; then
		rm /var/www/html/index.html
	fi
	if ! [ -e "/var/www/html/bin/kibana" ]; then
		wget $kibana_download_link
		tar xzf ./kibana*.tar.gz -C /var/www/html/ --strip 1
	fi

	# configure
	# make it start at boot
	# Not working
#	mkdir -p /opt/kibana/bin
#	cp /var/www/html/bin/kibana /opt/kibana/bin/
#	wget https://raw.githubusercontent.com/comperiosearch/vagrant-elk-box/master/kibana4_init
#	mv ./kibana4_init /etc/init.d/kibana
#	chmod 755 /etc/init.d/kibana
#	update-rc.d kibana defaults
}

install_logstash()
{
	if ! dpkg -s logstash | grep "Status"; then
		wget $logstash_download_link
		dpkg -i logstash*.deb
	fi

	# configure logstash
	# configure logstash pour utiliser 4 coeurs
	sed -i '/^#LS_OPTS=/c\LS_OPTS="-w 4"' /etc/default/logstash

	service logstash restart
}

install_elk()
{
	install_elasticsearch
	install_kibana
	install_logstash

	# start kibana
	/var/www/html/bin/kibana -l /var/log/kibana.log &
}

install_plaso()
{
	git clone https://github.com/log2timeline/plaso

	pip install ipython libbde-python libesedb-python libevt-python libevtx-python libewf-python libfwsi-python liblnk-python libmsiecf-python libolecf-python libqcow-python libregf-python libsigscan-python libsmdev-python libsmraw-python libvhdi-python libvmdk-python libvshadow-python python-bencode python-coveralls python-dateutil pytsk3 artifacts bencode binplist construct dfvfs dfwinreg dpkt xlsxwriter zmq ipython dfdatetime pycrypto
	apt-get -y install python-hachoir-core python-hachoir-metadata python-hachoir-parser python-pefile python-protobuf python-psutil python-pyparsing python-six python-yaml python-tz python-dateutil

	mkdir plaso_depencies
	cd plaso_depencies
	git clone https://github.com/libyal/libbde
	git clone https://github.com/libyal/libesedb
	git clone https://github.com/libyal/libevt
	git clone https://github.com/libyal/libevtx
	git clone https://github.com/libyal/libewf
	git clone https://github.com/libyal/libfsntfs
	git clone https://github.com/libyal/libfwsi
	git clone https://github.com/libyal/liblnk
	git clone https://github.com/libyal/libmsiecf
	git clone https://github.com/libyal/libolecf
	git clone https://github.com/libyal/libqcow
	git clone https://github.com/libyal/libregf
	git clone https://github.com/libyal/libscca
	git clone https://github.com/libyal/libsigscan
	git clone https://github.com/libyal/libsmdev
	git clone https://github.com/libyal/libsmraw
	git clone https://github.com/libyal/libvhdi
	git clone https://github.com/libyal/libvmdk
	git clone https://github.com/libyal/libvshadow

	for d in ./*
	do
		cd $d
		./synclibs.sh
		./autogen.sh
		./configure
		make
		make install
		python setup.py build
		python setup.py install
		cd ..
	done
	
	cd ../plaso/
	python setup.py build
	python setup.py install
}

if [ "$EUID" -ne 0 ]; then
	# si non root alors executer le script en root
	su root $0
else
	# installation des utilitaires
	apt-get -y install binutils gcc build-essential dkms default-jre-headless git linux-headers-$(uname -r) autotools-dev libsqlite3-dev python-dev debhelper devscripts fakeroot quilt mercurial python-setuptools libtool automake python-pip software-properties-common python-software-properties pkg-config libfuse-dev libssl-dev zlib1g-dev bzip2

	# installation logicile optionnels
	apt-get -y install vim

	# install elk
	install_elk

	# install plaso
	install_plaso
fi
