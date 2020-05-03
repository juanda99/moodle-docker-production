# php 7.4 not working yet, see https://tracker.moodle.org/browse/MDL-66260
FROM  php:7.3-apache-buster
LABEL MAINTAINER juanda <juandacorreo@gmail.com>

# Moodle version without . (38 means 3.8)
ARG VERSION=38

VOLUME ["/var/moodledata"]
EXPOSE 80

# Let the container know that there is no tty JUST WHEN INSTALLING!
# Later we can run docker -ti and we need interactivity

ARG DEBIAN_FRONTEND=noninteractive

## extensions based on https://github.com/moodlehq/moodle-php-apache/blob/master/Dockerfile
COPY php-extensions.sh /tmp
RUN /tmp/php-extensions.sh


# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

# usefull for moodle

RUN { \
	echo 'file_uploads = On'; \
	echo 'memory_limit = 256M'; \
	echo 'upload_max_filesize = 64M'; \
	echo 'post_max_size = 64M'; \
	echo 'max_execution_time = 600'; \
} > /usr/local/etc/php/conf.d/uploads.ini

RUN a2enmod rewrite expires

RUN	echo "Installing moodle" && \
		curl -o moodle.tgz -fSL "https://download.moodle.org/download.php/direct/stable${VERSION}/moodle-latest-${VERSION}.tgz"; \
		tar -xf moodle.tgz -C /usr/src/; \
		mkdir /var/www/moodledata && chown www-data:www-data /var/www/moodledata; \
		rm moodle.tgz

COPY moodle-config.php /usr/src/moodle/config.php
COPY docker-entrypoint.sh /usr/local/bin/

# Fix the original permissions of /tmp, the PHP default upload tmp dir.

RUN chmod 777 /tmp && chmod +t /tmp ;\
	chown -R www-data:www-data -R /usr/src/moodle

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]
