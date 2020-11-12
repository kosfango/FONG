#!/bin/sh

function check_docker {
docker_chk=`which docker`
compose_chk=`which docker-compose`

if [ -f "$docker_chk" ]

    then
	echo "Great! Docker found!"
    else
        echo "Exit. Docker not found. Please install docker!"
        exit 1
fi

if [ -f "$compose_chk" ]
    then
	echo "Great! Docker-compose found!"
    else
	echo "Exit. Docker-compose not foumd. Please install docker-compose!"
	exit 1
    fi

if [ -d /opt/fido-gui ]
    then
	echo "Error. Directory /opt/fido-gui already exist!"
        exit 1
    else
	return
fi

if [ `sed -n "/^fido/p" /etc/passwd` ]
    then
    return
    else
	echo "User fido doesn't exist"
    exit 1
fi


}
unset fUID
export fUID=$(id -u fido)

check_docker
mkdir -p /opt/fido-gui/etc
mkdir -p /opt/fido-gui/data/tmp/in
mkdir -p /opt/fido-gui/data/tmp/out
mkdir -p /opt/fido-gui/data/lib
mkdir -p /opt/fido-gui/data/etc
mkdir -p /opt/fido-gui/data/log
mkdir -p /opt/fido-gui/var/run
mkdir -p /opt/fido-gui/var/log
mkdir -p /opt/fido-gui/data/inbound
mkdir -p /opt/fido-gui/data/insecure
mkdir -p /opt/fido-gui/data/outbound
mkdir -p /opt/fido-gui/data/msg/dupe
mkdir -p /opt/fido-gui/data/fileareas

cp -R ./samples/binkd/* /opt/fido-gui/etc/
cp -R ./samples/husky/* /opt/fido-gui/data/etc

docker-compose -f ./docker-compose.yml up --build -d

#Entering variables
read -p 'Please enter your First Name: ' namevar
read -p 'Please enter your Second Name: ' surnamevar
read -p 'Please enter your Fidonet point address (4D format): ' nodeaddrrvar
read -p 'Please enter your station name: ' stnamevar
read -p 'Please enter location of your station (e.g.: Kostroma, Russia): ' locvar
echo " "

#Uplink
read -p 'Please enter uplink First Name: ' upnamevar
read -p 'Please enter uplink Second Name: ' upsurnamervar
read -p 'Please enter your uplink address 3D format: ' upnodeaddrrvar
read -p 'Please enter your uplink domain name or IP: ' upnodehostvar
read -sp 'Please enter password for your uplink: ' uppassvar
echo " "

#Editing fido config
sed -i "s/MyFirstName MySecondName/$namevar $surnamevar/g" /opt/fido-gui/data/etc/config
sed -i "s#2:5034\/17#$nodeaddrrvar#" /opt/fido-gui/data/etc/config
sed -i "s/TEST Station/$stnamevar/g" /opt/fido-gui/data/etc/config
sed -i "s/Kostroma, Russia/$locvar/g" /opt/fido-gui/data/etc/config
sed -i '/^hptperlfile/d' /opt/fido-gui/data/etc/config

#Editing links config
sed -i "s#2:5034/17#$nodeaddrrvar#g" /opt/fido-gui/data/etc/links
sed -i "s/UplinkFirstName UplinkSecondName/$upnamevar $upsurnamervar/g" /opt/fido-gui/data/etc/links
sed -i "s#2:9999/99#$upnodeaddrrvar#g" /opt/fido-gui/data/etc/links
sed -i "s/yourpassword/$uppassvar/g" /opt/fido-gui/data/etc/links
sed -i "s/pointpassword/$passvar/g" /opt/fido-gui/data/etc/links
sed -i "s#link MyFirstName MySecondName#link $namevar $surnamevar#g" /opt/fido-gui/data/etc/links

#Editing route config
sed -i "s#2:9999/99#$upnodeaddrrvar#" /opt/fido-gui/data/etc/route
sed -i "s#2:5034/17#${nodeaddrrvar}#" /opt/fido-gui/data/etc/route

#Editing binkdconfig
sed -i "s#2:5034\/17@fidonet#${nodeaddrrvar}@fidonet#" /opt/fido-gui/etc/binkd.conf
sed -i "s/TEST Station/$stnamevar/g" /opt/fido-gui/etc/binkd.conf
sed -i "s/Kostroma, Russia/$locvar/g" /opt/fido-gui/etc/binkd.conf
sed -i "s#MyFirstName MySecondName#${namevar} ${surnamevar}#" /opt/fido-gui/etc/binkd.conf
sed -i "s#2:9999/99@fidonet#${upnodeaddrrvar}@fidonet#" /opt/fido-gui/etc/binkd.conf
sed -i "s/domain.com/$upnodehostvar/g" /opt/fido-gui/etc/binkd.conf
sed -i "s/bosspassword/$uppassvar/g" /opt/fido-gui/etc/binkd.conf

#Tossing script
cp ./samples/toss.sh /opt/fido-gui/data/lib/toss.sh
cp ./samples/poll.sh /opt/fido-gui/data/lib/poll.sh
cp ./samples/menu.sh /opt/fido-gui/data/menu.sh
cp ./samples/.bash_login /opt/fido-gui/data/.bash_login
sed -i "s#2:9999/99#$upnodeaddrrvar#g" /opt/fido-gui/data/lib/poll.sh
chown -R fido:fido /opt/fido-gui
unset fUID
docker restart fido_point_gui
