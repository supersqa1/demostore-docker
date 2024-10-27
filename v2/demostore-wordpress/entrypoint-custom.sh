#!/bin/bash

set -x
set -e

# Check if URL argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <new-site-url>"
  exit 1
fi

NEW_URL="$1"

# Run the default WordPress entrypoint (adding & so that the next steps get executed)
/usr/local/bin/docker-entrypoint.sh apache2-foreground &


# wait until wordpress in installed completely (before doing wp-cli actions)
timeout=180
end_time=$((SECONDS + timeout))
while [[ $SECONDS -lt $end_time ]]; do
    if wp core is-installed --allow-root; then
        echo "wp is installed. done."
        break
    fi
    sleep 1
done


# replaceing the IP address. If not running locally 'WORDPRESS_IP' must be set for your sever ip address
WORDPRESS_IP=$WORDPRESS_IP
if [[ "$WORDPRESS_IP" != "0.0.0.0" ]]; then
    echo "Replacing IP address..."
    echo "New IP Address = $WORDPRESS_IP"
    wp search-replace 127.0.0.1 $WORDPRESS_IP --all-tables --allow-root
    wp search-replace 0.0.0.0 $WORDPRESS_IP --all-tables --allow-root
    echo "Done replacing IP address"
fi

# change owner of all folders in wp-content
chown -R www-data:www-data /var/www/html/wp-content

# Check if URL argument is provided
wp option update siteurl "$NEW_URL"
wp option update home "$NEW_URL"


# Keep the container running
tail -f /dev/null
