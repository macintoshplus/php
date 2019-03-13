#!/bin/sh
##
# Jb Nahan PHP 7.3 container
##

export DEBIAN_FRONTEND=noninteractive
# Sury : PHP Sources
apt-key add /root/sury.gpg
echo "deb https://packages.sury.org/php/ stretch main" > /etc/apt/sources.list.d/sury-php.list

# Blackfire
# wget -q -O - https://packagecloud.io/gpg.key | sudo apt-key add -
# echo "deb http://packages.blackfire.io/debian any main" >/etc/apt/sources.list.d/blackfire.list

# PHP
apt-get update && apt-get upgrade -y && apt-get -y install php7.3-dev php7.3-cli php7.3-bcmath php7.3-curl php-pear php7.3-gd php7.3-mbstring php7.3-mysql php7.3-sqlite3 php7.3-xmlrpc php7.3-xsl php7.3-ldap php7.3-gmp php7.3-intl php7.3-zip php7.3-soap php7.3-xml php7.3-common php7.3-json php7.3-opcache php7.3-readline 
# Disabled : blackfire-agent blackfire-php
# Disabled ext from repos :  php7.3-imagick php7.3-xdebug php7.3-apcu
# Disable dependencies : libmagickwand-6.q16-dev
# Disabled php-redis

sed -i 's/\;date\.timezone\ \=/date\.timezone\ \=\ Europe\/Paris/g' /etc/php/7.3/cli/php.ini
sed -i 's/\memory_limit\ \=\ 128M/memory_limit\ \=\ -1/g' /etc/php/7.3/cli/php.ini
sed -i 's/\display_errors\ \=\ Off/display_errors\ \=\ On/g' /etc/php/7.3/cli/php.ini
sed -i 's/disable_functions\ \=\ pcntl_alarm,pcntl_fork,pcntl_waitpid,pcntl_wait,pcntl_wifexited,pcntl_wifstopped,pcntl_wifsignaled,pcntl_wexitstatus,pcntl_wtermsig,pcntl_wstopsig,pcntl_signal,pcntl_signal_dispatch,pcntl_get_last_error,pcntl_strerror,pcntl_sigprocmask,pcntl_sigwaitinfo,pcntl_sigtimedwait,pcntl_exec,pcntl_getpriority,pcntl_setpriority,/\;disable_functions\ \=\ pcntl_alarm,pcntl_fork,pcntl_waitpid,pcntl_wait,pcntl_wifexited,pcntl_wifstopped,pcntl_wifsignaled,pcntl_wexitstatus,pcntl_wtermsig,pcntl_wstopsig,pcntl_signal,pcntl_signal_dispatch,pcntl_get_last_error,pcntl_strerror,pcntl_sigprocmask,pcntl_sigwaitinfo,pcntl_sigtimedwait,pcntl_exec,pcntl_getpriority,pcntl_setpriority,/g' /etc/php/7.3/cli/php.ini

pecl channel-update pecl.php.net
## Fix Tar Error
wget https://github.com/pear/Archive_Tar/releases/download/1.4.3/Archive_Tar-1.4.3.tgz
tar -xvf Archive_Tar-1.4.3.tgz
cp Archive_Tar-1.4.3/Archive/Tar.php /usr/share/php/Archive/Tar.php

pecl install sqlsrv-5.2.0 && pecl install pdo_sqlsrv-5.2.0
echo "extension=sqlsrv" > /etc/php/7.3/mods-available/sqlsrv.ini
echo "extension=pdo_sqlsrv" > /etc/php/7.3/mods-available/pdo_sqlsrv.ini

#PEAR
pear upgrade && pear install pecl/amqp-1.9.3
echo "extension=amqp" > /etc/php/7.3/mods-available/amqp.ini


pear install pecl/redis-4.2.0RC3
echo "extension=redis" > /etc/php/7.3/mods-available/redis.ini

apt install -y libmagickwand-dev libmagickcore-dev libmagickwand-6.q16-3 libmagickcore-6.q16-3
pear install pecl/imagick
echo "extension=imagick" > /etc/php/7.3/mods-available/imagick.ini

#git clone git://github.com/xdebug/xdebug.git
#cd xdebug
#git co 2.6.0beta1
#/usr/bin/phpize7.3 && ./configure --enable-xdebug && make && make install
pear install pecl/xdebug-2.7.0beta1
echo "zend_extension=xdebug" > /etc/php/7.3/mods-available/xdebug.ini

phpenmod -v 7.3 -s cli amqp sqlsrv pdo_sqlsrv redis xdebug imagick
# Disable : imagick

#useradd -s /bin/bash --home /sources --no-create-home phpuser

groupadd -g ${gid} phpuser
useradd -l -u ${uid} -g ${gid} -m -s /bin/bash phpuser
usermod -a -G www-data phpuser

apt-get remove -y libgcc-6-dev libmagickwand-dev libmagickcore-dev && apt autoremove -y
