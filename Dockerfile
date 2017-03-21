##
# Jb Nahan PHP 7.0 container
##

FROM            debian:testing
MAINTAINER  Jean-Baptiste Nahan <jean-baptiste@nahan.fr>

ENV         DEBIAN_FRONTEND noninteractive

# Common packages
RUN     echo "deb http://httpredir.debian.org/debian jessie-backports main contrib non-free" > /etc/apt/sources.list.d/jessie-backport.list
RUN     apt-get update && apt-get -y upgrade && apt-get -y install curl wget locales nano git subversion sudo librabbitmq-dev pdftk xfonts-75dpi libfontconfig1 libjpeg62-turbo libxrender1 xfonts-base fontconfig unixodbc-dev apt-transport-https gnupg locales-all libssl1.0.0

RUN     curl https://packages.microsoft.com/config/ubuntu/15.10/prod.list > /etc/apt/sources.list.d/mssql-release.list
#RUN     echo "deb http://packages.dotdeb.org jessie all" >> /etc/apt/sources.list.d/dotdeb.list && echo "deb-src http://packages.dotdeb.org jessie all" >> /etc/apt/sources.list.d/dotdeb.list && echo 'deb http://httpredir.debian.org/debian jessie-backports main' > /etc/apt/sources.list.d/jessie-backports.list
#RUN     wget https://www.dotdeb.org/dotdeb.gpg && apt-key add dotdeb.gpg
COPY    mysql_key.pub /root/
RUN     apt-key add /root/mysql_key.pub
RUN     echo "deb http://repo.mysql.com/apt/debian/ jessie mysql-5.7"  >> /etc/apt/sources.list.d/mysql.list
RUN     wget https://packages.microsoft.com/keys/microsoft.asc && apt-key add microsoft.asc

ENV 	JAVA_VERSION 8u121
ENV 	JAVA_DEBIAN_VERSION 8u121-b13-3
ENV 	CA_CERTIFICATES_JAVA_VERSION 20161107
ENV     ACCEPT_EULA Y
RUN     apt-get update && apt-get -y upgrade && apt-get install -y mysql-client msodbcsql mssql-tools wkhtmltopdf php7.0-dev openjdk-8-jre-headless="$JAVA_DEBIAN_VERSION" ca-certificates-java="$CA_CERTIFICATES_JAVA_VERSION"

RUN     echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> /root/.bash_profile && echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> /root/.bashrc && chmod +x /root/.bashrc && ./root/.bashrc
ENV     PATH "$PATH:/opt/mssql-tools/bin"

RUN 	/var/lib/dpkg/info/ca-certificates-java.postinst configure

RUN         echo "Europe/Paris" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata
RUN         export LANGUAGE=en_US.UTF-8 && \
        export LANG=en_US.UTF-8 && \
        export LC_ALL=en_US.UTF-8 && \
        locale-gen en_US.UTF-8 && \
        DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales

#COPY        bin/wkhtmltox-0.12.2.1_linux-jessie-amd64.deb /root/
#RUN     dpkg -i /root/wkhtmltox-0.12.2.1_linux-jessie-amd64.deb

# PHP
RUN     apt-get -y install php7.0-cli php7.0-curl php-pear php7.0-imagick php7.0-gd php7.0-mcrypt php7.0-mbstring php7.0-mysql php7.0-sqlite3 php7.0-xmlrpc php7.0-xsl php7.0-xdebug php7.0-apcu php7.0-ldap php7.0-gmp php7.0-intl php7.0-redis php7.0-zip php7.0-soap
RUN     sed -i 's/\;date\.timezone\ \=/date\.timezone\ \=\ Europe\/Paris/g' /etc/php/7.0/cli/php.ini
RUN     sed -i 's/\memory_limit\ \=\ 128M/memory_limit\ \=\ -1/g' /etc/php/7.0/cli/php.ini
RUN     sed -i 's/\display_errors\ \=\ Off/display_errors\ \=\ On/g' /etc/php/7.0/cli/php.ini
RUN     sed -i 's/disable_functions\ \=\ pcntl_alarm,pcntl_fork,pcntl_waitpid,pcntl_wait,pcntl_wifexited,pcntl_wifstopped,pcntl_wifsignaled,pcntl_wexitstatus,pcntl_wtermsig,pcntl_wstopsig,pcntl_signal,pcntl_signal_dispatch,pcntl_get_last_error,pcntl_strerror,pcntl_sigprocmask,pcntl_sigwaitinfo,pcntl_sigtimedwait,pcntl_exec,pcntl_getpriority,pcntl_setpriority,/\;disable_functions\ \=\ pcntl_alarm,pcntl_fork,pcntl_waitpid,pcntl_wait,pcntl_wifexited,pcntl_wifstopped,pcntl_wifsignaled,pcntl_wexitstatus,pcntl_wtermsig,pcntl_wstopsig,pcntl_signal,pcntl_signal_dispatch,pcntl_get_last_error,pcntl_strerror,pcntl_sigprocmask,pcntl_sigwaitinfo,pcntl_sigtimedwait,pcntl_exec,pcntl_getpriority,pcntl_setpriority,/g' /etc/php/7.0/cli/php.ini

RUN     pecl install sqlsrv && pecl install pdo_sqlsrv
RUN     echo "extension=sqlsrv.so" > /etc/php/7.0/mods-available/sqlsrv.ini
RUN     echo "extension=pdo_sqlsrv.so" > /etc/php/7.0/mods-available/pdo_sqlsrv.ini
RUN     cd /etc/php/7.0/cli/conf.d && ln -s ../../mods-available/sqlsrv.ini 20-sqlsrv.ini
RUN     cd /etc/php/7.0/cli/conf.d && ln -s ../../mods-available/pdo_sqlsrv.ini 20-pdo_sqlsrv.ini

#PEAR
RUN     pear upgrade && pear install pecl/amqp-1.7.1
RUN     echo "extension=amqp.so" > /etc/php/7.0/mods-available/amqp.ini
#RUN     cd /etc/php/7.0/apache2/conf.d && ln -s ../../mods-available/amqp.ini 20-amqp.ini
RUN     cd /etc/php/7.0/cli/conf.d && ln -s ../../mods-available/amqp.ini 20-amqp.ini
RUN     pear channel-discover pear.phpmd.org && pear channel-discover pear.pdepend.org && pear channel-discover pear.phpdoc.org && pear channel-discover components.ez.no
RUN     pear install PHP_CodeSniffer && pear install --alldeps phpmd/PHP_PMD
RUN     git clone https://github.com/lapistano/Symfony2-coding-standard.git /usr/share/php/PHP/CodeSniffer/Standards/Symfony2

RUN             useradd -s /bin/bash --home /sources --no-create-home phpuser
COPY            bin/fixright /
RUN             chmod +x /fixright

VOLUME      /sources

WORKDIR     /sources

