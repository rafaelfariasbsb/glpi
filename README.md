# glpi

Esse projeto baseado na imagem 
https://hub.docker.com/r/sdbrasil/glpi

GLPi - Instalação via Console do GLPI

docker exec -it glpi-10 /bin/bash

glpi-console glpi:database:install -L pt_BR -Hdb-glpi-10 -dglpi -uglpi -pGLP1_MySQL@10 --no-telemetry --force -n && mv /usr/share/glpi/install /usr/share/glpi/install_ori && rm -rf /var/log/glpi/* && chown -R apache:apache /usr/share/glpi/marketplace/ && chown -R apache:apache /var/lib/glpi/files && chown -R apache:apache /var/log/glpi && chown -R apache:apache /var/lib/glpi/files/data-documents
