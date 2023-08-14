#!/bin/bash
[[ ! "$VERSION_GLPI" ]] \
	&& VERSION_GLPI=$(curl -s https://api.github.com/repos/glpi-project/glpi/releases/latest | grep tag_name | cut -d '"' -f 4)

if [[ -z "${TIMEZONE}" ]]; then echo "TIMEZONE is unset"; 
else 
    sed -i "/;date.timezone =/c\date.timezone = $TIMEZONE" /etc/php.ini
fi


# Define variables
FOLDER_GLPI="/usr/share/glpi"
TEMP_DIR="/tmp"

# Check if the FOLDER_GLPI directory exists
if [ ! -d "$FOLDER_GLPI" ]; then
    echo "Directory $FOLDER_GLPI does not exist. Creating..."
    mkdir -p "$FOLDER_GLPI"

    # Download the file
    SRC_GLPI=$(curl -s https://api.github.com/repos/glpi-project/glpi/releases/tags/${VERSION_GLPI} | jq .assets[0].browser_download_url | tr -d \")
    TAR_GLPI=$(basename ${SRC_GLPI})
    echo "Downloading the GLPI archive..."
    wget "$SRC_GLPI" -P "$TEMP_DIR"

    # Check if the download was successful
    if [ -e "$TEMP_DIR/$TAR_GLPI" ]; then
        echo "Download successful."

        # Extract the archive
        echo "Extracting the archive..."
        tar -xzvf "$TEMP_DIR/$TAR_GLPI" -C "$TEMP_DIR"

        # Move to the FOLDER_GLPI directory
        mv "$TEMP_DIR/glpi" "$FOLDER_GLPI"

        # Delete the compressed archive
        rm -f "$TEMP_DIR/$TAR_GLPI"

        mkdir /usr/share/glpi/pics/imagens-custom /var/lib/glpi/files/data-documents 
       # create the downstream.php file

        
        echo "<?php" >> /usr/share/glpi/inc/downstream.php     
        echo "" >> /usr/share/glpi/inc/downstream.php     
        echo "// config" >> /usr/share/glpi/inc/downstream.php     
        echo "defined('GLPI_CONFIG_DIR') or define('GLPI_CONFIG_DIR',     (getenv('GLPI_CONFIG_DIR') ?: '/etc/glpi'));" >> /usr/share/glpi/inc/downstream.php     
        echo "" >> /usr/share/glpi/inc/downstream.php     && echo "if (file_exists(GLPI_CONFIG_DIR . '/local_define.php')) {" >> /usr/share/glpi/inc/downstream.php     
        echo "   require_once GLPI_CONFIG_DIR . '/local_define.php';" >> /usr/share/glpi/inc/downstream.php     
        echo "}" >> /usr/share/glpi/inc/downstream.php     
        echo "" >> /usr/share/glpi/inc/downstream.php     && echo "// marketplace plugins" >> /usr/share/glpi/inc/downstream.php     
        echo "defined('GLPI_MARKETPLACE_ALLOW_OVERRIDE') or define('GLPI_MARKETPLACE_ALLOW_OVERRIDE', false);" >> /usr/share/glpi/inc/downstream.php     
        echo "" >> /usr/share/glpi/inc/downstream.php     && echo "// runtime data" >> /usr/share/glpi/inc/downstream.php     
        echo "defined('GLPI_VAR_DIR')         or define('GLPI_VAR_DIR',         '/var/lib/glpi/files');" >> /usr/share/glpi/inc/downstream.php     
        echo "" >> /usr/share/glpi/inc/downstream.php     && echo "define('GLPI_DOC_DIR',        GLPI_VAR_DIR. '/data-documents');" >> /usr/share/glpi/inc/downstream.php     
        echo "define('GLPI_CRON_DIR',       GLPI_VAR_DIR . '/_cron');" >> /usr/share/glpi/inc/downstream.php     
        echo "define('GLPI_DUMP_DIR',       GLPI_VAR_DIR . '/_dumps');" >> /usr/share/glpi/inc/downstream.php     
        echo "define('GLPI_GRAPH_DIR',      GLPI_VAR_DIR . '/_graphs');" >> /usr/share/glpi/inc/downstream.php     
        echo "define('GLPI_LOCK_DIR',       GLPI_VAR_DIR . '/_lock');" >> /usr/share/glpi/inc/downstream.php     
        echo "define('GLPI_PICTURE_DIR',    GLPI_VAR_DIR . '/_pictures');" >> /usr/share/glpi/inc/downstream.php     
        echo "define('GLPI_PLUGIN_DOC_DIR', GLPI_VAR_DIR . '/_plugins');" >> /usr/share/glpi/inc/downstream.php     
        echo "define('GLPI_RSS_DIR',        GLPI_VAR_DIR . '/_rss');" >> /usr/share/glpi/inc/downstream.php     
        echo "define('GLPI_SESSION_DIR',    GLPI_VAR_DIR . '/_sessions');" >> /usr/share/glpi/inc/downstream.php     
        echo "define('GLPI_TMP_DIR',        GLPI_VAR_DIR . '/_tmp');" >> /usr/share/glpi/inc/downstream.php     
        echo "define('GLPI_UPLOAD_DIR',     GLPI_VAR_DIR . '/_uploads');" >> /usr/share/glpi/inc/downstream.php     
        echo "define('GLPI_CACHE_DIR',      GLPI_VAR_DIR . '/_cache');" >> /usr/share/glpi/inc/downstream.php     
        echo "" >> /usr/share/glpi/inc/downstream.php     
        echo "// log" >> /usr/share/glpi/inc/downstream.php     
        echo "defined('GLPI_LOG_DIR')         or define('GLPI_LOG_DIR',         '/var/log/glpi');" >> /usr/share/glpi/inc/downstream.php     
        echo "" >> /usr/share/glpi/inc/downstream.php     
        echo "// use system cron" >> /usr/share/glpi/inc/downstream.php     
        echo "define('GLPI_SYSTEM_CRON', true);" >> /usr/share/glpi/inc/downstream.php     
        echo "" >> /usr/share/glpi/inc/downstream.php

        # Change owner of the public folder to apache:apache
        chown -Rf apache:apache "$FOLDER_GLPI/public"
        chown -Rf apache:apache /var/lib/glpi/files 

        # Change permission of the glpi and files folder

        find /usr/share/glpi/ -type d -exec chmod 755 {} \; 
        find /usr/share/glpi/ -type f -exec chmod 644 {} \;  
        find /var/lib/glpi/files/ -type d -exec chmod 755 {} \; 
        find /var/lib/glpi/files/ -type f -exec chmod 644 {} \;      

        echo "Installation completed successfully."
    else
        echo "Error downloading the GLPI archive."
    fi
else
    echo "Directory $FOLDER_GLPI already exists. Skipping installation."
fi


sed -i "/upload_max_filesize =/c\upload_max_filesize = $UPLOAD_MAX_FILESIZE" /etc/php.ini 
sed -i "/post_max_size = /c\post_max_size = $POST_MAX_SIZE" /etc/php.ini
sed -i "/ServerName/c\ServerName $HOSTNAME" /etc/httpd/conf.d/ssl.conf
sed -i "/SSLCertificateFile/c\SSLCertificateFile /etc/pki/tls/certs/$SSLCERTIFICATEFILE" /etc/httpd/conf.d/ssl.conf
sed -i "/SSLCertificateKeyFile/c\SSLCertificateKeyFile /etc/pki/tls/private/$SSLCERTIFICATEKEYFILE" /etc/httpd/conf.d/ssl.conf
sed -i "/ServerName/c\ServerName $HOSTNAME" /etc/httpd/conf.d/glpi.conf

systemctl enable httpd
exec /usr/sbin/init