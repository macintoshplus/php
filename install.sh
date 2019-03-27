#!/bin/sh -ex
##
# Jb Nahan PHP 7.0 container
##

export  DEBIAN_FRONTEND=noninteractive

# Add Source List
wget -q -O - https://packages.sury.org/php/apt.gpg | sudo apt-key add -
echo "deb https://packages.sury.org/php/ stretch main" > /etc/apt/sources.list.d/sury-php.list

# PHP
apt-get update && apt-get -y upgrade && apt-get -y install php7.0-dev php7.0-cli php7.0-curl php-pear php7.0-imagick php7.0-gd php7.0-mcrypt php7.0-mbstring php7.0-mysql php7.0-sqlite3 php7.0-xmlrpc php7.0-xsl php7.0-xdebug php7.0-apcu php7.0-ldap php7.0-gmp php7.0-intl php7.0-redis php7.0-zip php7.0-soap php7.0-xml php7.0-common
sed -i 's/\;date\.timezone\ \=/date\.timezone\ \=\ Europe\/Paris/g' /etc/php/7.0/cli/php.ini
sed -i 's/\memory_limit\ \=\ 128M/memory_limit\ \=\ -1/g' /etc/php/7.0/cli/php.ini
sed -i 's/\display_errors\ \=\ Off/display_errors\ \=\ On/g' /etc/php/7.0/cli/php.ini
sed -i 's/disable_functions\ \=\ pcntl_alarm,pcntl_fork,pcntl_waitpid,pcntl_wait,pcntl_wifexited,pcntl_wifstopped,pcntl_wifsignaled,pcntl_wexitstatus,pcntl_wtermsig,pcntl_wstopsig,pcntl_signal,pcntl_signal_dispatch,pcntl_get_last_error,pcntl_strerror,pcntl_sigprocmask,pcntl_sigwaitinfo,pcntl_sigtimedwait,pcntl_exec,pcntl_getpriority,pcntl_setpriority,/\;disable_functions\ \=\ pcntl_alarm,pcntl_fork,pcntl_waitpid,pcntl_wait,pcntl_wifexited,pcntl_wifstopped,pcntl_wifsignaled,pcntl_wexitstatus,pcntl_wtermsig,pcntl_wstopsig,pcntl_signal,pcntl_signal_dispatch,pcntl_get_last_error,pcntl_strerror,pcntl_sigprocmask,pcntl_sigwaitinfo,pcntl_sigtimedwait,pcntl_exec,pcntl_getpriority,pcntl_setpriority,/g' /etc/php/7.0/cli/php.ini

pecl channel-update pecl.php.net
pecl install sqlsrv-4.3.0
pecl install pdo_sqlsrv-4.3.0
echo "extension=sqlsrv.so" > /etc/php/7.0/mods-available/sqlsrv.ini
echo "extension=pdo_sqlsrv.so" > /etc/php/7.0/mods-available/pdo_sqlsrv.ini

phpenmod sqlsrv pdo_sqlsrv

#PEAR
pear update-channels 
pear install pecl/amqp-1.9.1
echo "extension=amqp.so" > /etc/php/7.0/mods-available/amqp.ini

#pear install pecl/xdebug-2.6.1
#echo "zend_extension=xdebug.so" > /etc/php/7.0/mods-available/xdebug.ini

phpenmod amqp
#xdebug

useradd -s /bin/bash --home /sources --no-create-home phpuser

apt-get remove -y libgcc-6-dev php7.0-dev
apt-get autoremove -y

