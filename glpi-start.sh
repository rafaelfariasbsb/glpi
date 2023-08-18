#!/bin/bash

set -x
[[ ! "$VERSION_GLPI" ]] \
	&& VERSION_GLPI=$(curl -sk https://api.github.com/repos/glpi-project/glpi/releases/latest | grep tag_name | cut -d '"' -f 4)

if [[ -z "${TIMEZONE}" ]]; 
then 
    sed -i "/date.timezone =/c\date.timezone = Etc/UTC" /etc/php.ini
    rm -f /etc/localtime && ln -s /usr/share/zoneinfo/Etc/UTC /etc/localtime 
else 
    sed -i "/date.timezone =/c\date.timezone = $TIMEZONE" /etc/php.ini
    rm -f /etc/localtime && ln -s /usr/share/zoneinfo/$TIMEZONE /etc/localtime
fi
CURRENT_VERSION=$(ls "/usr/share/glpi/version/")

if [[ "${VERSION_GLPI//./}" -le "${CURRENT_VERSION//./}" ]]; then
    echo "Directory /usr/share/glpi/ already exists or you cannot downgrade version. Skipping installation."
else
    /opt/backup_glpi.sh
    mv /usr/share/glpi /backup/glpi-bkp-$VERSION_GLPI
    # Download the file
    SRC_GLPI=$(curl -sk https://api.github.com/repos/glpi-project/glpi/releases/tags/${VERSION_GLPI} | jq .assets[0].browser_download_url | tr -d \")
    TAR_GLPI=$(basename ${SRC_GLPI})
    echo "Downloading the GLPI archive..."
    wget "$SRC_GLPI" -P "/tmp"

    # Check if the download was successful
    if [ -e "/tmp/$TAR_GLPI" ]; then
        echo "Download successful."

        # Extract the archive
        echo "Extracting the archive..."
        tar -xzf "/tmp/$TAR_GLPI" -C /usr/share/ 

        # Delete the compressed archive
        rm -f "/tmp/$TAR_GLPI"
        cp -rp /backup/glpi-bkp-$VERSION_GLPI/inc/downstream.php /usr/share/glpi/inc/.
        cp -rp /backup/glpi-bkp-$VERSION_GLPI/plugins/* /usr/share/glpi/plugins/.
        cp -rp /backup/glpi-bkp-$VERSION_GLPI/marketplace/* /usr/share/glpi/marketplace/.
        rm -Rf /backup/glpi-bkp-$VERSION_GLPI

        # Change owner of the public folder to apache:apache
        chown -Rf apache:apache /usr/share/glpi/marketplace/                 
        chown -Rf apache:apache /usr/share/glpi/public/
        chown -Rf apache:apache /var/lib/glpi/files/
        chown -Rf apache:apache /var/log/glpi/

        

        # Change permission of the glpi and files folder

        find /usr/share/glpi/ -type d -exec chmod 755 {} \; 
        find /usr/share/glpi/ -type f -exec chmod 644 {} \;  
        find /var/lib/glpi/files/ -type d -exec chmod 755 {} \; 
        find /var/lib/glpi/files/ -type f -exec chmod 644 {} \;      

        echo "Installation completed successfully."
    else
        echo "Error downloading the GLPI archive."
    fi
fi

sed -i "/upload_max_filesize =/c\upload_max_filesize = $UPLOAD_MAX_FILESIZE" /etc/php.ini 
sed -i "/post_max_size = /c\post_max_size = $POST_MAX_SIZE" /etc/php.ini
sed -i "/ServerName/c\ServerName $HOSTNAME" /etc/httpd/conf.d/ssl.conf
sed -i "/SSLCertificateFile/c\SSLCertificateFile /etc/pki/tls/certs/$SSLCERTIFICATEFILE" /etc/httpd/conf.d/ssl.conf
sed -i "/SSLCertificateKeyFile/c\SSLCertificateKeyFile /etc/pki/tls/private/$SSLCERTIFICATEKEYFILE" /etc/httpd/conf.d/ssl.conf
sed -i "/ServerName/c\ServerName $HOSTNAME" /etc/httpd/conf.d/glpi.conf

systemctl enable httpd
exec /usr/sbin/init

