#!/bin/sh -x
##
# Jb Nahan Base container
##

apt-get update && apt-get -y upgrade && apt-get -y install curl wget locales nano git subversion sudo librabbitmq-dev xfonts-75dpi libfontconfig1 libjpeg62-turbo libxrender1 xfonts-base fontconfig unixodbc-dev apt-transport-https gnupg locales-all gnupg libssl1.1 pkg-config libmagickwand-dev zip
apt-get -y install pdftk
# Add Source List

apt-key add /root/mysql_key.pub && apt-key add /root/microsoft.asc

echo "deb http://repo.mysql.com/apt/debian/ stretch mysql-5.7"  >> /etc/apt/sources.list.d/mysql.list
#echo "deb https://packages.microsoft.com/ubuntu/16.10/prod yakkety main" > /etc/apt/sources.list.d/mssql-release.list
#echo "deb https://packages.microsoft.com/ubuntu/17.04/prod eoan main" >> /etc/apt/sources.list.d/mssql-release.list

curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list


# Environnement
export ACCEPT_EULA=Y
apt-get update && apt-get -y upgrade && apt-get install -y multiarch-support mysql-client msodbcsql17 mssql-tools ca-certificates-java

# Fix SQLSTATE[01000]: [unixODBC][Driver Manager]Can't open lib '/opt/microsoft/msodbcsql/lib64/libmsodbcsql-13.1.so.9.1' : file not found
#wget http://security-cdn.debian.org/debian-security/pool/updates/main/o/openssl/libssl1.0.0_1.0.1t-1+deb8u12_amd64.deb
#dpkg -i libssl1.0.0_1.0.1t-1+deb8u12_amd64.deb
#rm libssl1.0.0_1.0.1t-1+deb8u12_amd64.deb

echo 'export PATH="$PATH:/opt/mssql-tools/bins"' >> /root/.bash_profile && echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> /root/.bashrc && chmod +x /root/.bashrc
/root/.bashrc
export PATH="$PATH:/opt/mssql-tools/bin"

/var/lib/dpkg/info/ca-certificates-java.postinst configure

echo "Europe/Paris" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata
export LANGUAGE=en_US.UTF-8 && \
        export LANG=en_US.UTF-8 && \
        export LC_ALL=en_US.UTF-8 && \
        locale-gen en_US.UTF-8 && \
        DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales

apt remove -y libgcc-8-dev && apt-get autoremove -y && apt-get autoclean && apt-get clean
