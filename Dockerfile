FROM ubuntu:18.04

USER root

RUN export DEBIAN_FRONTEND=noninteractive
RUN ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime

RUN apt-get update && apt upgrade
RUN apt-get install -y autoconf gcc libc6 make wget unzip apache2 tzdata php libapache2-mod-php libgd-dev ufw
RUN dpkg-reconfigure --frontend noninteractive tzdata

WORKDIR /tmp
RUN wget -O nagioscore.tar.gz https://github.com/NagiosEnterprises/nagioscore/archive/nagios-4.4.6.tar.gz
RUN tar xzf nagioscore.tar.gz

WORKDIR /tmp/nagioscore-nagios-4.4.6/
RUN ./configure --with-httpd-conf=/etc/apache2/sites-enabled
RUN make all
RUN useradd nagios
RUN usermod -a -G nagios www-data
RUN make install
RUN make install-daemoninit
RUN make install-commandmode
RUN make install-config
RUN make install-webconf

RUN a2enmod rewrite
RUN a2enmod cgi

RUN ufw allow 'Apache'
RUN ufw reload

RUN /etc/init.d/apache2 restart
RUN /etc/init.d/nagios restart

WORKDIR /tmp
RUN wget --no-check-certificate -O nagios-plugins.tar.gz https://github.com/nagios-plugins/nagios-plugins/archive/release-2.4.0.tar.gz
RUN tar zxf nagios-plugins.tar.gz

WORKDIR /tmp/nagios-plugins-release-2.4.0
RUN ./tools/setup
RUN ./configure
RUN make
RUN make install