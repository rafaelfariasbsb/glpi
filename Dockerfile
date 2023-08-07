FROM almalinux/8-init
LABEL key="GLPI 10.0.9 e PHP 8.1"
ENV GLPI_LANG=pt_BR
RUN dnf -y update
RUN dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
RUN dnf -y install https://rpms.remirepo.net/enterprise/remi-release-8.rpm
RUN dnf config-manager --set-enabled powertools && dnf config-manager --set-enabled remi
RUN dnf -y install yum-plugin-copr && dnf -y copr enable ligenix/enterprise-glpi10 
RUN dnf -y module reset php \
    && dnf -y module install php:remi-8.1
RUN dnf -y install net-tools wget yum-utils bzip2 unzip tar patch php-pecl-zendopcache \
    php-opcache php-pecl-apcu php-soap php-xmlrpc php-pear-CAS php-snmp php-sodium glpi
RUN rm -f /etc/localtime && ln -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
RUN sed -i 's,;date.timezone =,date.timezone = America/Sao_Paulo,g' /etc/php.ini \
    && sed -i 's,upload_max_filesize = 2M,upload_max_filesize = 20M,g' /etc/php.ini \
    && sed -i 's,post_max_size = 8M,post_max_size = 20M,g' /etc/php.ini \
    && sed -i 's,session.cookie_httponly =,session.cookie_httponly = on,g' /etc/php.ini 
RUN mv /etc/httpd/conf.d/glpi.conf /etc/httpd/conf.d/glpi.conf_ori
COPY glpi.conf /etc/httpd/conf.d/
RUN sed -i 's/listen.acl_users = apache,nginx/;listen.acl_users = /g' /etc/php-fpm.d/www.conf \
    && sed -i 's/listen.acl_groups = /;listen.acl_groups = /g' /etc/php-fpm.d/www.conf \
    && sed -i 's/;listen.owner = nobody/listen.owner = apache/g' /etc/php-fpm.d/www.conf \
    && sed -i 's/;listen.group = nobody/listen.group = apache/g' /etc/php-fpm.d/www.conf 
ADD https://github.com/glpi-project/glpi/releases/download/10.0.9/glpi-10.0.9.tgz /tmp/
RUN mv /usr/share/glpi /usr/share/glpi-ori \
    && cd /tmp \
    && tar -zxf glpi-10.0.9.tgz -C /tmp/ \
    && mv /tmp/glpi /usr/share/. \
    && rm -rf glpi-10.0.9.tgz
RUN mkdir /usr/share/glpi/pics/imagens-custom
COPY downstream.php /usr/share/glpi/inc/
RUN systemctl enable httpd
EXPOSE 443 80 