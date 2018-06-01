##
# Jb Nahan Base container
##

FROM            debian:stable
MAINTAINER  Jean-Baptiste Nahan <jean-baptiste@nahan.fr>

ENV         DEBIAN_FRONTEND noninteractive

# Add Source List
COPY    certs/ /root/

COPY    install.sh /root/install.sh
RUN     chmod +x /root/install.sh
RUN     /root/install.sh
