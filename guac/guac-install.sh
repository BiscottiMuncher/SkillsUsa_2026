#!/bin/bash

# Need to set these
PW=""         # Another password
GUAC_DBPW="" #Password for the guacdb
REM_USER="" #IP of the Proxmox server

echo "INSTALLING GUAC"

apt-get update -y && apt-get upgrade -y && apt-get install sudo curl -y


apt install -y build-essential \
        libcairo2-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libtool-bin \
        uuid-dev \
        libossp-uuid-dev \
        libavcodec-dev \
        libavformat-dev \
        libavutil-dev \
        libswscale-dev \
        libpango1.0-dev \
        libssh2-1-dev \
        libvncserver-dev \
        libtelnet-dev \
        libwebsockets-dev \
        libssl-dev \
        libvorbis-dev \
        libwebp-dev \
        libpulse-dev 


VER=1.6.0
wget https://downloads.apache.org/guacamole/$VER/source/guacamole-server-$VER.tar.gz

tar xzf guacamole-server-$VER.tar.gz
cd guacamole-server-$VER
bash configure --with-systemd-dir=/etc/systemd/system/
#bash configure --with-systemd-dir=/etc/systemd/system/ --disable-guacenc
make && make install && ldconfig

systemctl daemon-reload
systemctl enable --now guacd

sed -i '/^::1/s/^/#/g' /etc/hosts
systemctl restart guacd

echo "deb http://deb.debian.org/debian/ bullseye main" > /etc/apt/sources.list.d/bullseye.list 
apt update && apt install tomcat9 tomcat9-admin tomcat9-common tomcat9-user -y
sed -i 's/^/#/' /etc/apt/sources.list.d/bullseye.list 

mkdir -p /etc/guacamole
VER=1.6.0
wget \
https://downloads.apache.org/guacamole/$VER/binary/guacamole-$VER.war \
-O /etc/guacamole/guacamole.war
ln -s /etc/guacamole/guacamole.war /var/lib/tomcat9/webapps/
systemctl restart tomcat9 guacd


## Maybe move later?
mkdir -p /etc/guacamole/{extensions,lib}
echo "GUACAMOLE_HOME=/etc/guacamole" >> /etc/default/tomcat9
cat > /etc/guacamole/guacamole.properties << EOL
guacd-hostname: 127.0.0.1
guacd-port: 4822
user-mapping:   /etc/guacamole/user-mapping.xml
auth-provider:  net.sourceforge.guacamole.net.basic.BasicFileAuthenticationProvider
EOL
ln -s /etc/guacamole /usr/share/tomcat9/.guacamole

#Skipper hardening with maria

apt install -y mariadb-server
systemctl enable --now mariadb

## Add two users, one local, one remote for python script
mariadb <<EOF
CREATE DATABASE IF NOT EXISTS guacd;
CREATE USER IF NOT EXISTS 'guacd_admin'@'localhost' IDENTIFIED BY '${GUAC_DBPW}';
GRANT SELECT,INSERT,UPDATE,DELETE ON guacd.* TO 'guacd_admin'@'localhost';
CREATE USER IF NOT EXISTS 'guacd_admin'@'${REM_USER}' IDENTIFIED BY '${GUAC_DBPW}';
GRANT SELECT,INSERT,UPDATE,DELETE ON guacd.* TO 'guacd_admin'@'${REM_USER}';
FLUSH PRIVILEGES;
EOF

## Setup bullshit connector
wget https://downloads.apache.org/guacamole/${VER}/binary/guacamole-auth-jdbc-${VER}.tar.gz
tar xzf guacamole-auth-jdbc-${VER}.tar.gz
cp guacamole-auth-jdbc-${VER}/mysql/guacamole-auth-jdbc-mysql-${VER}.jar /etc/guacamole/extensions/
cat guacamole-auth-jdbc-${VER}/mysql/schema/*.sql | mariadb guacd
wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-j-8.4.0.tar.gz
tar xzf mysql-connector-j-8.4.0.tar.gz
cp mysql-connector-j-8.4.0/mysql-connector-j-8.4.0.jar /etc/guacamole/lib/

## Change guac properties
cat > /etc/guacamole/guacamole.properties <<EOF
guacd-hostname: 127.0.0.1
guacd-port: 4822
mysql-hostname: localhost
mysql-database: guacd
mysql-username: guacd_admin
mysql-password: ${GUAC_DBPW}
EOF

# Fix ipv6 binding error that I hate with all my heart
sed -i 's|ExecStart=/usr/local/sbin/guacd -f|ExecStart=/usr/local/sbin/guacd -f -b 0.0.0.0|' /etc/systemd/system/guacd.service
# Open up maria for all writes on network given auth
sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf
#Final reload
systemctl daemon-reload
systemctl restart tomcat9 guacd

# Print out IP for ease of use
ip a
