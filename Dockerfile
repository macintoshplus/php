##
# Jb Nahan Base container
##

FROM            debian:testing
MAINTAINER  Jean-Baptiste Nahan <jean-baptiste@nahan.fr>

ENV         DEBIAN_FRONTEND noninteractive

# Common packages
#RUN     echo "deb http://httpredir.debian.org/debian stretch-backports main contrib non-free" > /etc/apt/sources.list.d/stretch-backport.list

RUN     apt-get update && apt-get -y upgrade && apt-get -y install curl wget locales nano git subversion sudo librabbitmq-dev pdftk xfonts-75dpi libfontconfig1 libjpeg62-turbo libxrender1 xfonts-base fontconfig unixodbc-dev apt-transport-https gnupg locales-all libssl1.0.2 pkg-config libmagickwand-dev

# Add Source List
COPY    certs/ /root/
RUN     apt-key add /root/mysql_key.pub && apt-key add /root/microsoft.asc
RUN     echo "deb http://repo.mysql.com/apt/debian/ stretch mysql-5.7"  >> /etc/apt/sources.list.d/mysql.list
RUN     echo "deb https://packages.microsoft.com/ubuntu/16.10/prod yakkety main" > /etc/apt/sources.list.d/mssql-release.list
RUN     echo "deb https://packages.microsoft.com/ubuntu/17.04/prod zesty main" >> /etc/apt/sources.list.d/mssql-release.list

# Environnement
ENV     ACCEPT_EULA Y
RUN     apt-get update && apt-get -y upgrade && apt-get install -y mysql-client msodbcsql mssql-tools wkhtmltopdf openjdk-8-jre-headless ca-certificates-java

RUN     echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> /root/.bash_profile && echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> /root/.bashrc && chmod +x /root/.bashrc
RUN     /root/.bashrc
ENV     PATH "$PATH:/opt/mssql-tools/bin"

RUN 	/var/lib/dpkg/info/ca-certificates-java.postinst configure

RUN         echo "Europe/Paris" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata
RUN         export LANGUAGE=en_US.UTF-8 && \
        export LANG=en_US.UTF-8 && \
        export LC_ALL=en_US.UTF-8 && \
        locale-gen en_US.UTF-8 && \
        DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales

