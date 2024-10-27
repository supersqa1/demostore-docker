FROM mysql:8.0


# start up mysql from a backup
COPY ./demostore_mysql_dump.sql /docker-entrypoint-initdb.d/


EXPOSE 3306
EXPOSE 3309