# Dockerfile for WordPress with WP-CLI
FROM wordpress:6.6.2

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp


# Copy the backup file into the containr.
# this file will be used to restore the site from the UI
COPY ./backups/0.0.0.0_wpvivid-fd8f3cd2701c3_2024-10-27-19-33_backup_all.zip  /var/www/html/wp-content/wpvividbackups/

# copy the wordpress core files
COPY ./wp-content /var/www/html/wp-content
