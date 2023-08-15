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
    php-opcache php-pecl-apcu php-soap php-xmlrpc php-pear-CAS php-snmp php-sodium glpi jq curl mod_ssl
RUN rm -f /etc/localtime && ln -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
RUN mv /etc/httpd/conf.d/glpi.conf /etc/httpd/conf.d/glpi.conf_ori
RUN mv /usr/share/glpi /usr/share/glpi_ori
COPY glpi.conf /etc/httpd/conf.d/
COPY ssl.conf /etc/httpd/conf.d/
RUN sed -i 's,session.cookie_httponly =,session.cookie_httponly = on,g' /etc/php.ini \
    && sed -i 's,;session.cookie_secure =,session.cookie_secure = on,g' /etc/php.ini \
    && sed -i 's/listen.acl_users = apache,nginx/;listen.acl_users = /g' /etc/php-fpm.d/www.conf \
    && sed -i 's/listen.acl_groups = /;listen.acl_groups = /g' /etc/php-fpm.d/www.conf \
    && sed -i 's/;listen.owner = nobody/listen.owner = apache/g' /etc/php-fpm.d/www.conf \
    && sed -i 's/;listen.group = nobody/listen.group = apache/g' /etc/php-fpm.d/www.conf   
EXPOSE 80 443 
COPY glpi-start.sh /opt/
RUN chmod +x /opt/glpi-start.sh
#ENTRYPOINT ["/usr/sbin/init","-D","FOREGROUND"]
ENTRYPOINT ["/opt/glpi-start.sh"]