##
# Jb Nahan PHP 7.1 container
##

FROM            macintoshplus/php:base
MAINTAINER  Jean-Baptiste Nahan <jean-baptiste@nahan.fr>

ENV         DEBIAN_FRONTEND noninteractive

COPY    certs/ /root/
RUN     apt-key add /root/sury.gpg
RUN 	echo "deb https://packages.sury.org/php/ stretch main" > /etc/apt/sources.list.d/sury-php.list

# PHP
RUN     apt-get update && apt-get upgrade -y && apt-get -y install php7.1-dev php7.1-cli php7.1-curl php-pear php7.1-imagick php7.1-gd php7.1-mcrypt php7.1-mbstring php7.1-mysql php7.1-sqlite3 php7.1-xmlrpc php7.1-xsl php7.1-apcu php7.1-ldap php7.1-gmp php7.1-intl php-redis php7.1-zip php7.1-soap php7.1-xml php7.1-common && apt-get autoremove -y && apt-get autoclean && apt-get clean
RUN     sed -i 's/\;date\.timezone\ \=/date\.timezone\ \=\ Europe\/Paris/g' /etc/php/7.1/cli/php.ini
RUN     sed -i 's/\memory_limit\ \=\ 128M/memory_limit\ \=\ -1/g' /etc/php/7.1/cli/php.ini
RUN     sed -i 's/\display_errors\ \=\ Off/display_errors\ \=\ On/g' /etc/php/7.1/cli/php.ini
RUN     sed -i 's/disable_functions\ \=\ pcntl_alarm,pcntl_fork,pcntl_waitpid,pcntl_wait,pcntl_wifexited,pcntl_wifstopped,pcntl_wifsignaled,pcntl_wexitstatus,pcntl_wtermsig,pcntl_wstopsig,pcntl_signal,pcntl_signal_dispatch,pcntl_get_last_error,pcntl_strerror,pcntl_sigprocmask,pcntl_sigwaitinfo,pcntl_sigtimedwait,pcntl_exec,pcntl_getpriority,pcntl_setpriority,/\;disable_functions\ \=\ pcntl_alarm,pcntl_fork,pcntl_waitpid,pcntl_wait,pcntl_wifexited,pcntl_wifstopped,pcntl_wifsignaled,pcntl_wexitstatus,pcntl_wtermsig,pcntl_wstopsig,pcntl_signal,pcntl_signal_dispatch,pcntl_get_last_error,pcntl_strerror,pcntl_sigprocmask,pcntl_sigwaitinfo,pcntl_sigtimedwait,pcntl_exec,pcntl_getpriority,pcntl_setpriority,/g' /etc/php/7.1/cli/php.ini

RUN     pecl channel-update pecl.php.net
RUN     pecl install sqlsrv && pecl install pdo_sqlsrv
RUN     echo "extension=sqlsrv.so" > /etc/php/7.1/mods-available/sqlsrv.ini
RUN     echo "extension=pdo_sqlsrv.so" > /etc/php/7.1/mods-available/pdo_sqlsrv.ini
RUN     phpenmod sqlsrv pdo_sqlsrv

#PEAR
RUN     pear upgrade && pear install pecl/amqp-1.9.1
RUN     echo "extension=amqp.so" > /etc/php/7.1/mods-available/amqp.ini
#RUN     cd /etc/php/7.1/apache2/conf.d && ln -s ../../mods-available/amqp.ini 20-amqp.ini
RUN     cd /etc/php/7.1/cli/conf.d && ln -s ../../mods-available/amqp.ini 20-amqp.ini
RUN     pear install pecl/xdebug
RUN     echo "zend_extension=/usr/lib/php/20160303/xdebug.so" > /etc/php/7.1/mods-available/xdebug.ini
RUN     phpenmod xdebug

#RUN     pear channel-discover pear.phpmd.org && pear channel-discover pear.pdepend.org && pear channel-discover pear.phpdoc.org && pear channel-discover components.ez.no
#RUN     pear install PHP_CodeSniffer && pear install --alldeps phpmd/PHP_PMD


RUN             useradd -s /bin/bash --home /sources --no-create-home phpuser
COPY            bin/fixright /
RUN             chmod +x /fixright

VOLUME      /sources

WORKDIR     /sources

