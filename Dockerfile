FROM centos:7

MAINTAINER Sergey Anokhin 2:5034/10.1

ARG fUID=1004

RUN cd /tmp && rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
    && rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm \
    && rpm -Uvh https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm \
    && yum update --exclude=kernel* --exclude=centos* -y && yum upgrade --exclude=kernel* --exclude=centos* -y \
    && yum groupinstall "Development Tools" -y \
    && yum install perl-ExtUtils-Embed.noarch qt3-devel.x86_64 qt3.x86_64 aspell-ru.x86_64 aspell-devel.x86_64 -y \
    && yum -y groupinstall "X Window System" "Fonts"

ENV PATH="/usr/lib64/qt-3.3/bin:${PATH}"
ENV QTDIR="/usr/lib64/qt-3.3${QTDIR}"
ENV QTINC="/usr/lib64/qt-3.3/include${QTINC}"
ENV QTLIB="/usr/lib64/qt-3.3/lib${QTLIB}"

RUN useradd -ms /bin/bash --uid=${fUID} fido \
    && ln -s /home/fido /fido \
    && mkdir /var/run/binkd && chown fido:fido /var/run/binkd && chown -R fido:fido /home/fido \
    && rm /etc/localtime && ln -snf /usr/share/zoneinfo/Europe/Moscow /etc/localtime \
    && mkdir -p /root/devel/husky \
    && cd /root/devel/husky \
    && git clone https://github.com/huskyproject/smapi.git \
    && git clone https://github.com/huskyproject/hpt.git \
    && git clone https://github.com/huskyproject/huskylib.git \
    && git clone https://github.com/huskyproject/huskybse.git \
    && git clone https://github.com/huskyproject/htick.git \
    && git clone https://github.com/huskyproject/fidoconf.git \
    && git clone https://github.com/huskyproject/areafix.git \
    && cp huskybse/huskymak.cfg ./huskymak.cfg \
    && sed -i 's/PERL=0/PERL=1/g' ./huskymak.cfg \
    && cd  ./huskylib && gmake && gmake install && gmake install-man \
    && cd ../smapi/ && gmake && gmake install \
    && cd ../fidoconf && gmake && gmake install && gmake install-man \
    && cd ../areafix && gmake && gmake install \
    && cd ../hpt && gmake && gmake install \
    && cd ../htick && gmake && gmake install && cd ./doc && make install \
    && echo "/usr/local/lib" > /etc/ld.so.conf.d/fido.conf \
    && ldconfig \
    && cd /root/devel && git clone https://github.com/pgul/binkd.git \
    && cd ./binkd && cp mkfls/unix/* . && sh ./configure && make && make install \
    && mkdir -p /usr/local/fido/etc && mkdir /usr/local/etc/fido \
    && ln -s /usr/local/fido/etc/config /usr/local/etc/fido/config \

##### QFE DEPLOYMENT
    && sed -i "s#initCharsets(VOID)#initCharsets()#g" /usr/local/include/huskylib/recode.h \
    && sed -i "s#doneCharsets(VOID)#doneCharsets()#g" /usr/local/include/huskylib/recode.h \
    && cd /root/devel && git clone https://github.com/evs38/qfe.git \
    && cd ./qfe && ./configure && sed -i "s#--gc-sections#-gc-sections#g" /root/devel/qfe/src/src.pro \
    && make && make install 

# Install ssh server.
RUN yum install -y which openssh-clients openssh-server
RUN ssh-keygen -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key \
    && sed -i "s/^.*X11Forwarding.*$/X11Forwarding yes/" /etc/ssh/sshd_config \
    && sed -i "s/^.*X11UseLocalhost.*$/X11UseLocalhost no/" /etc/ssh/sshd_config && grep "^X11UseLocalhost" /etc/ssh/sshd_config || echo "X11UseLocalhost no" >> /etc/ssh/sshd_config
RUN sed -i '/pam_loginuid.so/c session    optional     pam_loginuid.so'  /etc/pam.d/sshd

# Set root's password
RUN echo "root:centos" | chpasswd

# Set password for user fido
RUN echo "fido:123456" | chpasswd

ENTRYPOINT ["sh", "-c", "/usr/sbin/sshd && tail -f /dev/null"]