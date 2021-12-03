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
#Get UID and put into Dockerfile
unset fUID
export fUID=$(id -u fido)
sed -i "s#1004#${fUID}#" ./Dockerfile

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
mkdir -p /opt/fido-gui/data/golded

cp -R ./samples/binkd/* /opt/fido-gui/etc/
cp -R ./samples/husky/* /opt/fido-gui/data/etc
cp -R ./samples/golded/* /opt/fido-gui/data/golded

docker-compose -f ./docker-compose.yml up --build -d

cp -R /opt/fido-gui-back /opt/fido-gui

#Tossing script
cp ./samples/toss.sh /opt/fido-gui/data/lib/toss.sh
cp ./samples/poll.sh /opt/fido-gui/data/lib/poll.sh
cp ./samples/menu.sh /opt/fido-gui/data/menu.sh
cp ./samples/.bash_login /opt/fido-gui/data/.bash_login
sed -i "s#2:9999/99#$upnodeaddrrvar#g" /opt/fido-gui/data/lib/poll.sh
chown -R fido:fido /opt/fido-gui
unset fUID
docker restart fido_point_gui
