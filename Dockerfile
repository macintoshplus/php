##
# Jb Nahan PHP 7.2 container
##

FROM            macintoshplus/php:base
MAINTAINER  Jean-Baptiste Nahan <jean-baptiste@nahan.fr>

ENV         DEBIAN_FRONTEND noninteractive

COPY    certs/ /root/
RUN     apt-key add /root/sury.gpg
RUN 	echo "deb https://packages.sury.org/php/ stretch main" > /etc/apt/sources.list.d/sury-php.list

# PHP
RUN apt-get update && apt-get upgrade -y && apt-get -y install php7.2-dev php7.2-cli php7.2-curl php-pear php7.2-gd php7.2-mbstring php7.2-mysql php7.2-sqlite3 php7.2-xmlrpc php7.2-xsl php7.2-ldap php7.2-gmp php7.2-intl php7.2-zip php7.2-soap php7.2-xml php7.2-common php7.2-json php7.2-opcache php7.2-readline
# Disabled ext from repos :  php7.2-imagick php7.2-xdebug php7.2-apcu
# Disabled php-redis

RUN     sed -i 's/\;date\.timezone\ \=/date\.timezone\ \=\ Europe\/Paris/g' /etc/php/7.2/cli/php.ini
RUN     sed -i 's/\memory_limit\ \=\ 128M/memory_limit\ \=\ -1/g' /etc/php/7.2/cli/php.ini
RUN     sed -i 's/\display_errors\ \=\ Off/display_errors\ \=\ On/g' /etc/php/7.2/cli/php.ini
RUN     sed -i 's/disable_functions\ \=\ pcntl_alarm,pcntl_fork,pcntl_waitpid,pcntl_wait,pcntl_wifexited,pcntl_wifstopped,pcntl_wifsignaled,pcntl_wexitstatus,pcntl_wtermsig,pcntl_wstopsig,pcntl_signal,pcntl_signal_dispatch,pcntl_get_last_error,pcntl_strerror,pcntl_sigprocmask,pcntl_sigwaitinfo,pcntl_sigtimedwait,pcntl_exec,pcntl_getpriority,pcntl_setpriority,/\;disable_functions\ \=\ pcntl_alarm,pcntl_fork,pcntl_waitpid,pcntl_wait,pcntl_wifexited,pcntl_wifstopped,pcntl_wifsignaled,pcntl_wexitstatus,pcntl_wtermsig,pcntl_wstopsig,pcntl_signal,pcntl_signal_dispatch,pcntl_get_last_error,pcntl_strerror,pcntl_sigprocmask,pcntl_sigwaitinfo,pcntl_sigtimedwait,pcntl_exec,pcntl_getpriority,pcntl_setpriority,/g' /etc/php/7.2/cli/php.ini

RUN     pecl channel-update pecl.php.net
## Fix Tar Error
RUN     wget https://github.com/pear/Archive_Tar/releases/download/1.4.3/Archive_Tar-1.4.3.tgz
RUN     tar -xvf Archive_Tar-1.4.3.tgz
RUN     cp Archive_Tar-1.4.3/Archive/Tar.php /usr/share/php/Archive/Tar.php

RUN     pecl install sqlsrv-5.0.0preview && pecl install pdo_sqlsrv-5.0.0preview
RUN     echo "extension=sqlsrv.so" > /etc/php/7.2/mods-available/sqlsrv.ini
RUN     echo "extension=pdo_sqlsrv.so" > /etc/php/7.2/mods-available/pdo_sqlsrv.ini
#RUN     cd /etc/php/7.2/cli/conf.d && ln -s ../../mods-available/sqlsrv.ini 20-sqlsrv.ini
#RUN     cd /etc/php/7.2/cli/conf.d && ln -s ../../mods-available/pdo_sqlsrv.ini 20-pdo_sqlsrv.ini
RUN     phpenmod -v 7.2 -s cli sqlsrv pdo_sqlsrv

#PEAR
RUN     pear upgrade && pear install pecl/amqp-1.9.1
RUN     echo "extension=amqp.so" > /etc/php/7.2/mods-available/amqp.ini
#RUN     cd /etc/php/7.2/apache2/conf.d && ln -s ../../mods-available/amqp.ini 20-amqp.ini
#RUN     cd /etc/php/7.2/cli/conf.d && ln -s ../../mods-available/amqp.ini 20-amqp.ini
RUN     phpenmod -v 7.2 -s cli amqp


RUN     pear install pecl/redis
RUN     echo "extension=redis.so" > /etc/php/7.2/mods-available/redis.ini
#RUN     cd /etc/php/7.2/apache2/conf.d && ln -s ../../mods-available/redis.ini 20-redis.ini
#RUN     cd /etc/php/7.2/cli/conf.d && ln -s ../../mods-available/redis.ini 20-redis.ini
RUN     phpenmod -v 7.2 -s cli redis

RUN     pear install pecl/imagick
RUN     echo "extension=imagick.so" > /etc/php/7.2/mods-available/imagick.ini
#RUN     cd /etc/php/7.2/apache2/conf.d && ln -s ../../mods-available/imagick.ini 20-imagick.ini
#RUN     cd /etc/php/7.2/cli/conf.d && ln -s ../../mods-available/imagick.ini 20-imagick.ini
RUN     phpenmod -v 7.2 -s cli imagick

RUN     git clone git://github.com/xdebug/xdebug.git
RUN     cd xdebug && /usr/bin/phpize7.2 && ./configure --enable-xdebug && make && make install
RUN     echo "zend_extension=xdebug.so" > /etc/php/7.2/mods-available/xdebug.ini
#RUN     cd /etc/php/7.2/cli/conf.d && ln -s ../../mods-available/xdebug.ini 20-xdebug.ini
RUN     phpenmod -v 7.2 -s cli xdebug


RUN     pear channel-discover pear.phpmd.org && pear channel-discover pear.pdepend.org && pear channel-discover pear.phpdoc.org && pear channel-discover components.ez.no
RUN     pear install PHP_CodeSniffer && pear install --alldeps phpmd/PHP_PMD


RUN             useradd -s /bin/bash --home /sources --no-create-home phpuser
COPY            bin/fixright /
RUN             chmod +x /fixright

VOLUME      /sources

WORKDIR     /sources

