FROM wordpress:6.2.2


# Download and install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp
 
# Update the 'wp-content' with the backup content
RUN rm -rf /var/www/html/wp-content
COPY ./wp-content/ /var/www/html/wp-content/

# copy custom entrypoint to image. This overrides the custom entrypoint script.
# It runs the default entrypoint script, and after wordpress is isntalled it runs
# wp-cli command to update the IP address of the site (replace 0.0.0.0 in database by user provided ip)
COPY ./entrypoint-custom.sh /entrypoint-custom.sh
RUN chmod +x /entrypoint-custom.sh
