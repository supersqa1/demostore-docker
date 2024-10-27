FROM mysql:5.7


# start up mysql from a backup
COPY ./demostore_mysql_dump.2.sql /docker-entrypoint-initdb.d/


EXPOSE 3306
EXPOSE 3309