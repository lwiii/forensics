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

libbde="https://github.com/libyal/libbde/releases/download/20160418/libbde-alpha-20160418.tar.gz"
libesedb="https://github.com/libyal/libesedb/releases/download/20151213/libesedb-experimental-20151213.tar.gz"
libevt="https://github.com/libyal/libevt/releases/download/20160107/libevt-alpha-20160107.tar.gz"
libevtx="https://github.com/libyal/libevtx/releases/download/20160107/libevtx-alpha-20160107.tar.gz"
libewf="https://github.com/libyal/libewf/releases/download/20160403/libewf-experimental-20160403.tar.gz"
libfsntfs="https://github.com/libyal/libfsntfs/releases/download/20160418/libfsntfs-experimental-20160418.tar.gz"
libfwsi="https://github.com/libyal/libfwsi/releases/download/20160110/libfwsi-experimental-20160110.tar.gz"
liblnk="https://github.com/libyal/liblnk/releases/download/20160107/liblnk-alpha-20160107.tar.gz"
libmsiecf="https://github.com/libyal/libmsiecf/releases/download/20160107/libmsiecf-alpha-20160107.tar.gz"
libolecf="https://github.com/libyal/libolecf/releases/download/20160107/libolecf-alpha-20160107.tar.gz"
libqcow="https://github.com/libyal/libqcow/releases/download/20160123/libqcow-alpha-20160123.tar.gz"
libregf="https://github.com/libyal/libregf/releases/download/20160107/libregf-alpha-20160107.tar.gz"
libscca="https://github.com/libyal/libscca/releases/download/20160108/libscca-alpha-20160108.tar.gz"
libsigscan="https://github.com/libyal/libsigscan/releases/download/20160312/libsigscan-experimental-20160312.tar.gz"
libsmdev="https://github.com/libyal/libsmdev/releases/download/20160320/libsmdev-alpha-20160320.tar.gz"
libsmraw="https://github.com/libyal/libsmraw/releases/download/20160108/libsmraw-alpha-20160108.tar.gz"
libvhdi="https://github.com/libyal/libvhdi/releases/download/20160108/libvhdi-alpha-20160108.tar.gz"
libvmdk="https://github.com/libyal/libvmdk/releases/download/20160119/libvmdk-alpha-20160119.tar.gz"
libvshadow="https://github.com/libyal/libvshadow/releases/download/20160110/libvshadow-alpha-20160110.tar.gz"


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

	pip install ipython libbde-python libesedb-python libevt-python libevtx-python libewf-python libfwsi-python liblnk-python libmsiecf-python libolecf-python libqcow-python libregf-python libsigscan-python libsmdev-python libsmraw-python libvhdi-python libvmdk-python libvshadow-python python-bencode python-coveralls python-dateutil pytsk3 artifacts bencode binplist construct dfvfs dfwinreg dpkt xlsxwriter zmq dfdatetime pycrypto pefile
	apt-get -y install python-hachoir-core python-hachoir-metadata python-hachoir-parser python-protobuf python-psutil python-pyparsing python-six python-yaml python-tz python-dateutil

	mkdir plaso_depencies
	cd plaso_depencies

	wget $libbde
	wget $libesedb
	wget $libevt
	wget $libevtx
	wget $libewf
	wget $libfsntfs
	wget $libfwsi
	wget $liblnk
	wget $libmsiecf
	wget $libolecf
	wget $libqcow
	wget $libregf
	wget $libscca
	wget $libsigscan
	wget $libsmdev
	wget $libsmraw
	wget $libvhdi
	wget $libvmdk
	wget $libvshadow

	for f in ./*.tar.gz
	do
		tar -xvf $f
		rm $f
	done

	for d in ./*
	do
		cd $d
		./configure --enable-python
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
