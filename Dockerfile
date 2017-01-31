##
# Jb Nahan PHP 5.6 container
##

FROM            debian:jessie
MAINTAINER  Jean-Baptiste Nahan <jean-baptiste@nahan.fr>

ENV         DEBIAN_FRONTEND noninteractive
RUN     apt-get update && apt-get -y upgrade

# Common packages
RUN         apt-get -y install curl wget locales nano git subversion sudo php5-dev librabbitmq-dev

RUN         echo "Europe/Paris" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata
RUN         export LANGUAGE=en_US.UTF-8 && \
        export LANG=en_US.UTF-8 && \
        export LC_ALL=en_US.UTF-8 && \
        locale-gen en_US.UTF-8 && \
        DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales

# Apache 
RUN     apt-get -y install pdftk mysql-client xfonts-75dpi libfontconfig1 libjpeg62-turbo libxrender1 xfonts-base fontconfig

COPY        bin/wkhtmltox-0.12.2.1_linux-jessie-amd64.deb /root/
RUN     dpkg -i /root/wkhtmltox-0.12.2.1_linux-jessie-amd64.deb

# PHP
RUN     apt-get -y install php5-cli php5-curl php-soap php5-imagick php5-gd php5-mcrypt php5-mysql php5-xmlrpc php5-xsl php5-xdebug php-apc php5-apcu php5-ldap php5-gmp php5-intl php5-redis php5-sqlite
RUN         cp /usr/share/php5/php.ini-development /etc/php5/cli/php.ini
RUN         sed -i 's/\;date\.timezone\ \=/date\.timezone\ \=\ Europe\/Paris/g' /etc/php5/cli/php.ini
RUN         sed -i 's/\memory_limit\ \=\ 128M/memory_limit\ \=\ -1/g' /etc/php5/cli/php.ini
RUN             sed -i 's/disable_functions\ \=\ pcntl_alarm,pcntl_fork,pcntl_waitpid,pcntl_wait,pcntl_wifexited,pcntl_wifstopped,pcntl_wifsignaled,pcntl_wexitstatus,pcntl_wtermsig,pcntl_wstopsig,pcntl_signal,pcntl_signal_dispatch,pcntl_get_last_error,pcntl_strerror,pcntl_sigprocmask,pcntl_sigwaitinfo,pcntl_sigtimedwait,pcntl_exec,pcntl_getpriority,pcntl_setpriority,/\;disable_functions\ \=\ pcntl_alarm,pcntl_fork,pcntl_waitpid,pcntl_wait,pcntl_wifexited,pcntl_wifstopped,pcntl_wifsignaled,pcntl_wexitstatus,pcntl_wtermsig,pcntl_wstopsig,pcntl_signal,pcntl_signal_dispatch,pcntl_get_last_error,pcntl_strerror,pcntl_sigprocmask,pcntl_sigwaitinfo,pcntl_sigtimedwait,pcntl_exec,pcntl_getpriority,pcntl_setpriority,/g' /etc/php5/cli/php.ini
#RUN        sed -i 's/;include_path = ".:\/usr\/share\/php"/include_path = ".:\/var\/www\/library"/g' /etc/php5/cli/php.ini

RUN     wget https://github.com/FriendsOfPHP/pickle/releases/download/v0.4.0/pickle.phar
RUN     php pickle.phar install xdebug

#PEAR
RUN     pear upgrade && pear install pecl/amqp-1.7.0 && pear install pecl/xdebug
RUN     echo "extension=amqp.so" > /etc/php5/mods-available/amqp.ini
#RUN     cd /etc/php5/apache2/conf.d && ln -s ../../mods-available/amqp.ini 20-amqp.ini
RUN     cd /etc/php5/cli/conf.d && ln -s ../../mods-available/amqp.ini 20-amqp.ini
RUN     pear channel-discover pear.phpmd.org && pear channel-discover pear.pdepend.org && pear channel-discover pear.phpdoc.org && pear channel-discover components.ez.no
RUN     pear install PHP_CodeSniffer && pear install --alldeps phpmd/PHP_PMD
RUN     git clone https://github.com/lapistano/Symfony2-coding-standard.git /usr/share/php/PHP/CodeSniffer/Standards/Symfony2

RUN             useradd -s /bin/bash --home /src --no-create-home phpuser
COPY            bin/fixright /
RUN             chmod +x /fixright

VOLUME      /src

WORKDIR     /src

