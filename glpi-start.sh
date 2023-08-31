#!/bin/bash

set -x


sed -i "/date.timezone =/c\date.timezone = $TIMEZONE" /etc/php.ini
rm -f /etc/localtime && ln -s /usr/share/zoneinfo/$TIMEZONE /etc/localtime

mv /tmp/certificado/$SSLCERTIFICATEFILE /etc/pki/tls/certs/ 
mv /tmp/certificado/$SSLCERTIFICATEKEYFILE /etc/pki/tls/private/

sed -i "/upload_max_filesize =/c\upload_max_filesize = $UPLOAD_MAX_FILESIZE" /etc/php.ini 
sed -i "/post_max_size = /c\post_max_size = $POST_MAX_SIZE" /etc/php.ini
sed -i "/ServerName/c\ServerName $HOSTNAME" /etc/httpd/conf.d/ssl.conf
sed -i "/SSLCertificateFile/c\SSLCertificateFile /etc/pki/tls/certs/$SSLCERTIFICATEFILE" /etc/httpd/conf.d/ssl.conf
sed -i "/SSLCertificateKeyFile/c\SSLCertificateKeyFile /etc/pki/tls/private/$SSLCERTIFICATEKEYFILE" /etc/httpd/conf.d/ssl.conf
sed -i "/ServerName/c\ServerName $HOSTNAME" /etc/httpd/conf.d/glpi.conf

systemctl enable httpd
exec /usr/sbin/init

