#!/bin/bash
USER="user"
PASSWORD="passwd"
HOST="host"
mysql -u $USER -p$PASSWORD -h $HOST --silent -e 'SELECT table_schema "DB Name", Round(Sum(data_length + index_length) / 1024 / 1024, 1) "DB Size in Mb" FROM information_schema.tables GROUP BY table_schema;'
mysql -u $USER -p$PASSWORD -h $HOST --silent -e "show master status;" > binlogposition_1.log
databases=`mysql -u $USER -p$PASSWORD -h $HOST --silent  -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`
for db in $databases; do
    if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != _* ]] ; then
        echo "Dumping database: $db"
        mysqldump -u $USER -p$PASSWORD -h $HOST --single-transaction --order-by-primary --compress  $db > `date +%Y%m%d`.$db.sql
    fi
done

# Uncomment the following line for a single file with all databases in compressed form
# mysqldump -u $USER -p$PASSWORD -h $HOST --single-transaction --order-by-primary --compress --all-databases --triggers --routines --events  > `date +%Y%m%d`.fc_dump.sql
### Backup users and privileges
mysql -u $USER -p$PASSWORD -h $HOST --skip-column-names -A -e "SELECT CONCAT('CREATE USER ','\'',user,'\'@\'',host,'\'','  IDENTIFIED BY PASSWORD ','\'',password,'\';') from mysql.user;" > Users.sql
mysql -u $USER -p$PASSWORD -h $HOST --skip-column-names -A -e "SELECT CONCAT('SHOW GRANTS FOR ''',user,'''@''',host,''';') AS query FROM mysql.user WHERE user NOT IN ('root','pma','rdsadmin','mysql.sys')" | mysql -u $USER -p$PASSWORD -h $HOST --skip-column-names -A | sed 's/$/;/g' | sed 's/IDENTIFIED BY PASSWORD <secret>//g' >> Users.sql
echo "flush privileges;" >> Users.sql