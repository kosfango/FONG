FROM centos:7

MAINTAINER Sergey Anokhin 2:5034/10.1

ARG fUID=1004

ENV PATH="/usr/lib64/qt-3.3/bin:${PATH}"
ENV QTDIR="/usr/lib64/qt-3.3${QTDIR}"
ENV QTINC="/usr/lib64/qt-3.3/include${QTINC}"
ENV QTLIB="/usr/lib64/qt-3.3/lib${QTLIB}"

COPY ./samples/golded/mygolded.h /root/devel/mygolded.h

RUN cd /tmp && rpm --import http://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7 \
    && rpm --import http://rpms.famillecollet.com/RPM-GPG-KEY-remi \
    && rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org

RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
    && rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm \
    && rpm -Uvh https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm \
    && yum update --exclude=kernel* --exclude=centos* -y && yum upgrade --exclude=kernel* --exclude=centos* -y \
    && yum groupinstall "Development Tools" "X Window System" "Fonts" -y \
    && yum install deltarpm perl-ExtUtils-Embed.noarch qt3-devel.x86_64 qt3.x86_64 aspell-ru.x86_64 aspell-devel.x86_64 which ncurses-devel openssh-clients openssh-server xorg-x11-apps xterm screen -y \
    && useradd -ms /bin/bash --uid=${fUID} fido \
    && ln -s /home/fido /fido \
    && mkdir /var/run/binkd && chown fido:fido /var/run/binkd && chown -R fido:fido /home/fido \
    && rm /etc/localtime && ln -snf /usr/share/zoneinfo/Europe/Moscow /etc/localtime

RUN mkdir -p /root/devel/husky \
    && cd /root/devel/husky \
    && git clone https://github.com/huskyproject/smapi.git \
    && git clone https://github.com/huskyproject/hpt.git \
    && git clone https://github.com/huskyproject/huskylib.git \
    && git clone https://github.com/huskyproject/huskybse.git \
    && git clone https://github.com/huskyproject/htick.git \
    && git clone https://github.com/huskyproject/fidoconf.git \
    && git clone https://github.com/huskyproject/areafix.git \
    && cd ./huskybse && git checkout 22d109383260025883d652740699fcd0a6bf03c5 \
    && cp ./huskymak.cfg ../huskymak.cfg \
    && sed -i 's/PERL=0/PERL=1/g' ../huskymak.cfg \
    && cd ../huskylib && git checkout baf8805b4dfc901a1ab88c0764c0151ad960073c && gmake && gmake install && gmake install-man \
    && cd ../smapi && git checkout 501a0d59f14f7e0c262e4b98bee0d5454638c684 && gmake && gmake install \
    && cd ../fidoconf &&  git checkout 774f3b8b7e0fe069fd9703de0ea1839ff012d413 && gmake && gmake install && gmake install-man \
    && cd ../areafix && git checkout 1f96d4bbc17a84fea69f910dab44d58aa223f226 && gmake && gmake install \
    && cd ../hpt && git checkout b2e86a0651fd9614d8d62dd8d11c76d6befb8f76 && gmake && gmake install \
    && cd ../htick && git checkout cff33aa4461a66e38dac72db33b6bd6a7a35e444 && gmake && gmake install && cd ./doc && make install \
    && echo "/usr/local/lib" > /etc/ld.so.conf.d/fido.conf \
    && ldconfig \
    && cd /root/devel && git clone https://github.com/pgul/binkd.git \
    && cd ./binkd && cp mkfls/unix/* . && sh ./configure && make && make install \
    && mkdir -p /usr/local/fido/etc && mkdir /usr/local/etc/fido \
    && ln -s /usr/local/fido/etc/config /usr/local/etc/fido/config
##### QFE DEPLOYMENT
RUN sed -i "s#initCharsets(VOID)#initCharsets()#g" /usr/local/include/huskylib/recode.h \
    && sed -i "s#doneCharsets(VOID)#doneCharsets()#g" /usr/local/include/huskylib/recode.h \
    && cd /root/devel && git clone https://github.com/evs38/qfe.git \
    && cd ./qfe && ./configure && sed -i "s#--gc-sections#-gc-sections#g" /root/devel/qfe/src/src.pro \
    && make && make install
RUN cd /root/devel && git clone https://github.com/golded-plus/golded-plus \
    && cd ./golded-plus && cp /root/devel/mygolded.h ./golded3/ && /bin/bash dist-gpl.sh && /bin/bash dist-gpc.sh \
    && cd .. && ls && unzip gpl80707.zip -d /usr/local/fido/golded ; chmod +x /usr/local/fido/golded/golded && unzip gpc80707.zip -d /usr/local/fido/golded ; chown -R fido:fido /usr/local/fido \
    && cp /usr/local/fido/golded/gedlnx /usr/local/bin/ \
##### Install ssh server.
    && ssh-keygen -f /etc/ssh/ssh_host_rsa_key \
    && ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key \
    && sed -i "s/^.*X11Forwarding.*$/X11Forwarding yes/" /etc/ssh/sshd_config \
    && sed -i "s/^.*X11UseLocalhost.*$/X11UseLocalhost no/" /etc/ssh/sshd_config && grep "^X11UseLocalhost" /etc/ssh/sshd_config || echo "X11UseLocalhost no" >> /etc/ssh/sshd_config \
    && sed -i '/pam_loginuid.so/c session    optional     pam_loginuid.so'  /etc/pam.d/sshd \
#### Set root's password
    && echo "root:centos" | chpasswd \
#### Set password for user fido
    && echo "fido:123456" | chpasswd

ENTRYPOINT ["sh", "-c", "/usr/sbin/sshd && tail -f /dev/null"]
