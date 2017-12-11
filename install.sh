#!/bin/sh
##
# Jb Nahan PHP 7.0 container
##

export DEBIAN_FRONTEND=noninteractive
apt-key add /root/sury.gpg
echo "deb https://packages.sury.org/php/ stretch main" > /etc/apt/sources.list.d/sury-php.list

# PHP
apt-get update && apt-get upgrade -y && apt-get -y install php7.2-dev php7.2-cli php7.2-bcmath php7.2-curl php-pear php7.2-gd php7.2-mbstring php7.2-mysql php7.2-sqlite3 php7.2-xmlrpc php7.2-xsl php7.2-ldap php7.2-gmp php7.2-intl php7.2-zip php7.2-soap php7.2-xml php7.2-common php7.2-json php7.2-opcache php7.2-readline
# Disabled ext from repos :  php7.2-imagick php7.2-xdebug php7.2-apcu
# Disabled php-redis

sed -i 's/\;date\.timezone\ \=/date\.timezone\ \=\ Europe\/Paris/g' /etc/php/7.2/cli/php.ini
sed -i 's/\memory_limit\ \=\ 128M/memory_limit\ \=\ -1/g' /etc/php/7.2/cli/php.ini
sed -i 's/\display_errors\ \=\ Off/display_errors\ \=\ On/g' /etc/php/7.2/cli/php.ini
sed -i 's/disable_functions\ \=\ pcntl_alarm,pcntl_fork,pcntl_waitpid,pcntl_wait,pcntl_wifexited,pcntl_wifstopped,pcntl_wifsignaled,pcntl_wexitstatus,pcntl_wtermsig,pcntl_wstopsig,pcntl_signal,pcntl_signal_dispatch,pcntl_get_last_error,pcntl_strerror,pcntl_sigprocmask,pcntl_sigwaitinfo,pcntl_sigtimedwait,pcntl_exec,pcntl_getpriority,pcntl_setpriority,/\;disable_functions\ \=\ pcntl_alarm,pcntl_fork,pcntl_waitpid,pcntl_wait,pcntl_wifexited,pcntl_wifstopped,pcntl_wifsignaled,pcntl_wexitstatus,pcntl_wtermsig,pcntl_wstopsig,pcntl_signal,pcntl_signal_dispatch,pcntl_get_last_error,pcntl_strerror,pcntl_sigprocmask,pcntl_sigwaitinfo,pcntl_sigtimedwait,pcntl_exec,pcntl_getpriority,pcntl_setpriority,/g' /etc/php/7.2/cli/php.ini

pecl channel-update pecl.php.net
## Fix Tar Error
wget https://github.com/pear/Archive_Tar/releases/download/1.4.3/Archive_Tar-1.4.3.tgz
tar -xvf Archive_Tar-1.4.3.tgz
cp Archive_Tar-1.4.3/Archive/Tar.php /usr/share/php/Archive/Tar.php

pecl install sqlsrv-5.1.1preview && pecl install pdo_sqlsrv-5.1.1preview
echo "extension=sqlsrv.so" > /etc/php/7.2/mods-available/sqlsrv.ini
echo "extension=pdo_sqlsrv.so" > /etc/php/7.2/mods-available/pdo_sqlsrv.ini

#PEAR
pear upgrade && pear install pecl/amqp-1.9.3
echo "extension=amqp.so" > /etc/php/7.2/mods-available/amqp.ini


pear install pecl/redis
echo "extension=redis.so" > /etc/php/7.2/mods-available/redis.ini

pear install pecl/imagick
echo "extension=imagick.so" > /etc/php/7.2/mods-available/imagick.ini

git clone git://github.com/xdebug/xdebug.git
cd xdebug
git co XDEBUG_2_5_5
/usr/bin/phpize7.2 && ./configure --enable-xdebug && make && make install
echo "zend_extension=xdebug.so" > /etc/php/7.2/mods-available/xdebug.ini

phpenmod -v 7.2 -s cli amqp sqlsrv pdo_sqlsrv redis imagick xdebug

useradd -s /bin/bash --home /sources --no-create-home phpuser

apt-get remove -y libgcc-6-dev libgcc-7-dev && apt autoremove -y
