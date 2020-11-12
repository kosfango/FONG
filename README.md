# FIDONET-ONECLICK with GUI
# Experimental project for automatically deployment of FIDONET software using Docker and Docker-compose

Run main_script.sh and enjoy!  

Ports usage:  
63022 - sshd for X11 tunnel  

ssh login: fido  
password: 123456  

Helpful arguments if you are using Xming:  
"C:\Program Files (x86)\Xming\Xming.exe" :0 -clipboard -multiwindow -xkblayout us,ru -xkbvariant winkeys -xkboptions grp:ctrl_shift_toggle -screen 0 800x600  

Putty:
Enable X11 forwarding  
X display location: localhost:0  

REQUIREMENTS:

- Linux
- docker
- docker-compose
- Directory /opt/fido-gui will be created automatically
- You should to create user fido on host machine!

INCLUDE:
- Husky + Binkd + QFE (1 container)
