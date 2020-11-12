# FIDONET-ONECLICK with GUI
# Экспериментальный проект для быстрого развертывания поинтового комплекта для сети FIDONET, с использованием Docker и Docker-compose

Запустить скрипт main_script.sh и откинуться на спинку кресла!  

Используемые порты:  
63022 - sshd for X11 tunnel  

Учетка для доступа:  
login: fido  
password: 123456  

Если вы пользователь OS Windows и Xming, то возможно это вам пригодится:  
"C:\Program Files (x86)\Xming\Xming.exe" :0 -clipboard -multiwindow -xkblayout us,ru -xkbvariant winkeys -xkboptions grp:ctrl_shift_toggle -screen 0 800x600  

Настройка Putty:
Enable X11 forwarding  
X display location: localhost:0  

ТРЕБОВАНИЯ:

- Linux
- docker
- docker-compose
- Directory /opt/fido-gui will будет создано автоматически
- Вам необходимо создать пользователя fido на хост-машине!

ЧТО ВНУТРИ:
- Husky + Binkd + QFE (один контейнер)
