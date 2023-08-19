
#!/bin/bash
set -x
# Define o diretório de backup do GLPI
DIR="/backup/glpi/sql";
if [ ! -d $DIR ]; then
    mkdir -p $DIR
    chmod -R 0777 $DIR
fi
# Define o formato do nome do arquivo de backup
DB="glpi-DB-`date +%d_%m_%Y-%H_%M`"

# Gerando o arquivo SQL com o mysqldump.
#IP MySQL LOCAL

mysqldump --no-tablespaces -u$MYSQL_USER -h$MYSQL_CONTAINER_NAME -p$MYSQL_PASSWORD $MYSQL_DATABASE > $DIR/$DB.sql
# Verifica se o diretório existe, se não ele irá criar e dar permissão


# Abrindo o diretório
cd $DIR

# Compactando o arquivo para que não fique muito grande
tar -zcf $DB.tar.gz $DB.sql

# Removendo o arquivo original para liberar espaço
rm -f $DIR/$DB.sql

# Removendo arquivos com mais de 15 dias
find $DIR/*.tar.gz -ctime +15 -exec rm -rf {} \;

# Define o diretório da Aplicacao do GLPI
DIR="/backup/glpi/app";
if [ ! -d $DIR ]; then
    mkdir -p $DIR
    chmod -R 0777 $DIR
fi
# Removendo o backup da instalação completa anterior
rm -f $DIR/glpi_app.tar.gz

# Refaz o backup da instalação completa
tar -zcf $DIR/glpi_app.tar.gz /usr/share/glpi

# Define o diretório Lib do GLPI
DIR="/backup/glpi/app";

if [ ! -d $DIR ]; then
    mkdir -p $DIR
    chmod -R 0777 $DIR
fi

# Removendo o backup da instalação completa anterior
rm -f $DIR/glpi_lib.tar.gz

# Refaz o backup da instalação completa
tar -zcf $DIR/glpi_lib.tar.gz /var/lib/glpi

# Define o diretório do DB do GLPI
DIR="/backup/glpi/app";
if [ ! -d $DIR ]; then
    mkdir -p $DIR
    chmod -R 0777 $DIR
fi

# Removendo o backup da instalação completa anterior
rm -f $DIR/glpi_db.tar.gz

# Refaz o backup da instalação completa
tar -zcf $DIR/glpi_db.tar.gz /etc/glpi

# Define o diretório de LOG do GLPI
DIR="/backup/glpi/app";
if [ ! -d $DIR ]; then
    mkdir -p $DIR
    chmod -R 0777 $DIR
fi

# Removendo o backup da instalação completa anterior
rm -f $DIR/glpi_log.tar.gz

# Refaz o backup da instalação completa
tar -zcf $DIR/glpi_log.tar.gz /var/log/glpi
