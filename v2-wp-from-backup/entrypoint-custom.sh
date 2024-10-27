#!/bin/bash

set -x
set -e


# Run the default WordPress entrypoint (adding & so that the next steps get executed)
/usr/local/bin/docker-entrypoint.sh apache2-foreground &

export HTTP_HOST=$(echo "$SITE_URL" | awk -F[/:] '{print $4}')


echo "AAAAAAAAAAA"
# wp core is-installed --allow-root
ls -la /var/www/html/
echo "BBBBBBB"
echo "CCCCCCC"
sleep 60
ls -la /var/www/html/
echo "DDDDDDD"
# wp core is-installed --allow-root

# wait until wordpress in installed completely (before doing wp-cli actions)
# timeout=180
# end_time=$((SECONDS + timeout))
# while [[ $SECONDS -lt $end_time ]]; do
#     if wp core is-installed --allow-root; then
#         echo "wp is installed. done."
#         break
#     fi
#     sleep 1
# done

# Setup wordpress
ADMIN_USER=admin
ADMIN_PASSWORD=password
ADMIN_EMAIL=admas@supersqa.com
echo "XXXXXXXXX"

echo "Seting up wordpress"
wp core install --url="$SITE_URL" --title='Demo eCom Store' --admin_user="$ADMIN_USER" --admin_email="$ADMIN_EMAIL" --admin_password="$ADMIN_PASSWORD" --allow-root

echo "ZZZZZZZ"
# install WPVivid backup plugin
echo "Installing plugin: wpvivid-backuprestore"
wp plugin install wpvivid-backuprestore --activate --allow-root

# change owner of all folders in wp-content
echo "Chaning owner of '/var/www/html/wp-content' to www-data"
chown -R www-data:www-data /var/www/html/wp-content


# Keep the container running
tail -f /dev/null
