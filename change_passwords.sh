#!/bin/bash
set -x
set -e

############## NOTE ############
# This script is used to update the MySQL root password, the WordPress user password,
# and the WordPress admin user password for a WordPress instance running in a Docker container. 

# If running on local machine you do not need to update the passwords but you can if you want.

# Before running this script, make sure to set the following environment variables:
#
# NEW_MYSQL_ROOT_PASSWORD: The new password for the MySQL 'root' user. This password is used to access the MySQL server.
# NEW_WORDPRESS_MYSQL_PASSWORD: The new password for the 'wordpress' user used by WordPress to connect to the database.#
# NEW_WORDPRESS_ADMIN_PASSWORD: The new password for the WordPress 'admin' user. This password is used to access the WordPress admin dashboard.
# 
# Example Usage:
# Before running the script, set the required environment variables like this:
#
# export NEW_MYSQL_ROOT_PASSWORD=mynewrootpassword
# export NEW_WORDPRESS_MYSQL_PASSWORD=mynewwordpresspassword
# export NEW_WORDPRESS_ADMIN_PASSWORD=mynewadminpassword

# Make sure to replace 'mynewrootpassword', 'mynewwordpresspassword', and 'mynewadminpassword' with your desired passwords.
# Note: For security reasons, avoid using simple or easily guessable passwords.
#
# Then run the script:
# sh update_passwords.sh



############## USER SETTINGS ############
# Check if the environment variables are set
# Check if the environment variables are set
if [[ -z "${NEW_MYSQL_ROOT_PASSWORD}" || -z "${NEW_WORDPRESS_MYSQL_PASSWORD}" || -z "${NEW_WORDPRESS_ADMIN_PASSWORD}" ]]; then
    echo "ERROR: Environment variables NEW_MYSQL_ROOT_PASSWORD, NEW_WORDPRESS_MYSQL_PASSWORD, and NEW_WORDPRESS_ADMIN_PASSWORD must be set."
    exit 1
fi

# this is the password to login to the database as 'root' user
NEW_MYSQL_ROOT_PASSWORD=${NEW_MYSQL_ROOT_PASSWORD}

# This is the password for username 'wordpress'. This is the user WordPress uses to connect to the database.
NEW_WORDPRESS_MYSQL_PASSWORD=${NEW_WORDPRESS_MYSQL_PASSWORD}

# this is the name of your mysql container for wordpress. 
# If you dont modify the 'docker-compose.yml' then this will be 'my_mysql_container'
MYSQL_CONTAINER_NAME=my_mysql_container


############# STARTING TO APPLY CHANGES #########
# Change the password for 'root' user in MySQL and set the host to '%'
echo "Changing password for 'root' user...."
docker exec -i $MYSQL_CONTAINER_NAME mysql -uroot -ppassword <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '$NEW_MYSQL_ROOT_PASSWORD';
ALTER USER 'root'@'%' IDENTIFIED BY '$NEW_MYSQL_ROOT_PASSWORD';
FLUSH PRIVILEGES;
EOF


# Change the password for the 'wordpress' user in MySQL
echo "Changing password for 'wordpress' user...."
docker exec -i $MYSQL_CONTAINER_NAME mysql -uroot -p$NEW_MYSQL_ROOT_PASSWORD <<EOF
ALTER USER 'wordpress'@'%' IDENTIFIED BY '$NEW_WORDPRESS_MYSQL_PASSWORD';
FLUSH PRIVILEGES;
EOF


# update wordpress to use the new password
echo "Updating WordPress to use the new password ...."
docker exec -it my_wordpress_container wp config set DB_PASSWORD $NEW_WORDPRESS_MYSQL_PASSWORD --allow-root

# Update the password for the WordPress admin user
# This is the password used to loging to <your site>/wp-admin (backend of WordPress)
echo "Updating WordPress 'admin' user password...."
docker exec -it my_wordpress_container wp user update 1 --user_pass="$NEW_WORDPRESS_ADMIN_PASSWORD" --allow-root


# Verify MySQL root password
if docker exec $MYSQL_CONTAINER_NAME mysql -uroot -p"$NEW_MYSQL_ROOT_PASSWORD" -e "SELECT 1;" &>/dev/null; then
    echo "Successfully connected to MySQL with the new root password."
else
    echo "Failed to connect to MySQL with the new root password."
fi

# Verify WordPress user password
if docker exec $MYSQL_CONTAINER_NAME mysql -uroot -p"$NEW_MYSQL_ROOT_PASSWORD" -e "SELECT 1 FROM mysql.user WHERE User='wordpress' AND Host='%';" &>/dev/null; then
    echo "Successfully connected to MySQL with the new WordPress user password."
else
    echo "Failed to connect to MySQL with the new WordPress user password."
fi

# Verify WordPress configuration
if docker exec -it my_wordpress_container wp core is-installed --allow-root; then
    echo "WordPress is correctly installed and connected to the database."
else
    echo "Failed to verify WordPress installation and database connection."
fi



# Verify WordPress admin user password
if docker exec -it my_wordpress_container wp user check-password 1 "$NEW_WORDPRESS_ADMIN_PASSWORD" --allow-root &>/dev/null; then
    echo "Successfully updated the WordPress admin user password."
else
    echo "Failed to update the WordPress admin user password."
fi
