FROM almalinux/8-init
RUN dnf -y update
RUN dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
RUN dnf -y install https://rpms.remirepo.net/enterprise/remi-release-8.rpm
RUN dnf config-manager --set-enabled powertools && dnf config-manager --set-enabled remi
RUN dnf -y install yum-plugin-copr && dnf -y copr enable ligenix/enterprise-glpi10 
RUN dnf -y module reset php \
    && dnf -y module install php:remi-8.1
RUN dnf -y install net-tools wget yum-utils bzip2 unzip tar patch php-pecl-zendopcache \
    php-opcache php-pecl-apcu php-soap php-xmlrpc php-pear-CAS php-snmp php-sodium glpi jq curl mod_ssl mysql
COPY glpi.conf /etc/httpd/conf.d/
COPY ssl.conf /etc/httpd/conf.d/
COPY downstream.php /usr/share/glpi/inc/
COPY php.ini /etc/
COPY www.conf /etc/php-fpm.d/ 
COPY backup_glpi.sh /opt/
RUN chmod +x /opt/backup_glpi.sh
RUN mkdir -p /usr/share/glpi/pics/imagens-custom /var/lib/glpi/files/data-documents
COPY glpi-start.sh /opt/
RUN chmod +x /opt/glpi-start.sh
EXPOSE 80 443 
ENTRYPOINT ["/opt/glpi-start.sh"]