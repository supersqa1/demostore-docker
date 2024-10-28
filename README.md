# DemoStore SuperSQA with Docker

This repository contains a Docker Compose setup for deploying a web application using WordPress and MySQL. It provides a convenient way to set up and run the application in a containerized environment.

This will ba preconfigured e-commerce application with some sample products.
Example site: http://demostore.supersqa.com

This is docker containers will run exact copy of the site mentioned above.

## Versions
* version = "demostore-basic" (recomended version)
  - This version will use custom wp image but original mysql image
  - It contains 'wp-content' folder & a backup '.zip' for WPVivid
  - It uses custom wordpress image `supersqa/demostore-wordpress:basic-with-backup`
  - To run
    - just run docker compose `docker-compose up -d`
    - go though the installion proces. Just put random name and keep password simple. All that will change when we restore from backup
    - Login to `.com/wp-admin` and got to `plugins`
    - The 'WPVivid Backup' pluing should already exist, just activate it
    - It should open config page, click the blue button that says 'scan for backups'. Then you should see a backkup show up.
    - Click on restore and follow prompts.
    - The site should be up and it will log out 
    - Login with `admin` and `password`
    - Run the `change_passwords.sh` to set new password for wordpress and mysql

* version = "v1"
  - is the original version that has WP 6.6 and older versions of the plugins.
  - The original automation code was written for this version
  - Images used for this version are `supersqa/demostore-mysql:5.7` and `supersqa/demostore-wordpress:6.2.2`
  - The ports used are `7575` for wordpress and `3309` (for external connection) for MySQL
  - The `docker-compose.v1.yml` will create containers for virsion 1 (V1)




## Prerequisites

Before getting started, make sure you have the following installed on your machine:
There is a script 'install_docker_ubuntu.sh'. This experimental script and you can try to run it. If that does not work please check the official documentation. When running the script just hit "ENTER" when you get prompts for your input.

- Docker: [Installation Guide](https://docs.docker.com/get-docker/)
- Docker Compose: [Installation Guide](https://docs.docker.com/compose/install/)

## Usage
2 Images are needed to run WordPress. The 'wordpress' image and 'mysql' image. The best way to run it is to use docker-compose.

For the images there are 2 ways to get them:
    1. Use existing images from Docker Hub.
    2. Build your own images

## Important
* Change the passwords by running the 'change_passwords.sh' script. (<b>if running locally no need to change passwords but if you are running it on publicly accessible server you MUST change the passwords.</b>)
* You must use port <b>7575</b> for the host machine (The site is accessed with port 7575)
* You must set variable '<b>WORDPRESS_IP</b>' if you are not running it on local. If running the site on IP other than 0.0.0.0. For example, if you have a VPS with port xx.xxx.xxx.x then you have to set variable WORDPRESS_IP=xx.xxx.xxx.x. <b>If running on local you do not need the variable.</b>
* You can connect to the database with a MySQL client like MySQL Workbench using port <b>3309</b>

### Option 1: Use existing images
Example docker-compose.yml (You can just download the one in this repo and run it)

<b>DO NOT CHANGE THE PASSWORDS IN THE docker-compose.yml </b>
Since this is a copy of pre configured site, changing password here will break it. You will change the passwords after the containers are running. A script to change passwords is provided.
```
version: '3.8'

services:
  db:
    image: supersqa/demostore-mysql:5.7
    restart: always
    container_name: my_mysql_container
    ports:
      - 3309:3306
    environment:
      MYSQL_ROOT_PASSWORD: password
      MYSQL_DATABASE: demostore
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: password


  wordpress:
    depends_on:
      - db
    image: supersqa/demostore-wordpress:6.2.2
    container_name: my_wordpress_container
    ports:
      - "7575:80"
    restart: always
    environment:
      WORDPRESS_DB_HOST: my_mysql_container:3306
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: password
      WORDPRESS_DB_NAME: demostore
      WORDPRESS_IP: ${WORDPRESS_IP:-0.0.0.0}
    entrypoint: /entrypoint-custom.sh
```

### Command to run the containers
```
$ cd <directory where docker-compose.yml is>
$ WORDPRESS_IP=123.45.678.0 docker-compose up -d
```
Access the e-commerce site
```
http://123.45.678.0:7575
```
or if running on local
```
http://0.0.0.0:7575
```
To check if containers are running
```
$ docker ps
```
You should see two containers with names
```
CONTAINER ID   IMAGE                                COMMAND                  CREATED         STATUS         PORTS                                         NAMES
148bc2176eca   supersqa/demostore-wordpress:6.2.2   "/entrypoint-custom.…"   5 seconds ago   Up 2 seconds   0.0.0.0:7575->80/tcp                          my_wordpress_container
3d81e1284d25   supersqa/demostore-mysql:5.7         "docker-entrypoint.s…"   5 seconds ago   Up 3 seconds   3309/tcp, 33060/tcp, 0.0.0.0:3309->3306/tcp   my_mysql_container
```
If you do not see both containers
```
$ docker ps -a
```
If the containers exited check the logs with commands like this
```
$ docker logs -f my_wordpress_container
$ docker logs -f my_mysql_container
```

### Changing the passwords
If your site is publicly accessible you must change the passwords. Because anyone that is aware of this repository can access your site using the default passwords.
There are 3 passwords that must be changes.
* The password for the MySQL 'root' user
* The password for the 'wordpress' user (the user that WordPress uses to connect to db)
* The password for the wordpress 'admin' user.

The default passowrds are
* Mysql root password = password
* WordPress database password = password
* Wordpress 'admin' user password = password

Script 'change_passwords.sh' is provided. 
<br>
Here is how you should run the script.
First set your new passwords as environment variables.
```
export NEW_MYSQL_ROOT_PASSWORD=mynewrootpassword
export NEW_WORDPRESS_MYSQL_PASSWORD=mynewwordpresspassword
export NEW_WORDPRESS_ADMIN_PASSWORD=mynewadminpassword
export NEW_WORDPRESS_ADMIN_PASSWORD=mynewadminpassword
export CURRENT_MYSQL_ROOT_PASSWORD=password (the default is password if you have not changed it yet)

``````
Make sure to replace 'mynewrootpassword', 'mynewwordpresspassword', and 'mynewadminpassword' with your desired passwords.

Note: For security reasons, avoid using simple or easily guessable passwords.
#

Then execute the script
```
sh change_passwords.sh
```

### Option 2: Build your own images
After buling images replace the 'supersqa/demostore-mysql:5.7' and 'supersqa/demostore-wordpress:6.2.2' in the docker-compose.yml file with name/tag of your own images.

<b>Build the 'wordpress' image</b>
```
cd demostore-wordpress
docker build -t <your image name> .
```

<b>Build the 'mysql' image</b>
```
cd demostore-mysql
docker build -t <your image name> .
```
When you create your own images, the default password 'password' is still used.

<b> If you are running the site on publicly accesible servier, then changing your passwords is still required even if you create your own images. Follow the instructions above on how to change your password. </b>