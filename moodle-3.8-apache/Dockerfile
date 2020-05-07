# php 7.4 not working yet, see https://tracker.moodle.org/browse/MDL-66260
FROM  php:7.3-apache-buster
LABEL MAINTAINER juanda <juandacorreo@gmail.com>

ARG VERSION=3.8.2
ARG MOOSH_VERSION=0.32
ARG COMPOSER_VERSION=1.10.6

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
		curl -o moodle.tar.gz -fSL "https://github.com/moodle/moodle/archive/v${VERSION}.tar.gz"; \
		mkdir /usr/src/moodle; \
		tar -xf moodle.tar.gz -C /usr/src/moodle --strip 1; \
		rm moodle.tar.gz

RUN	echo "Installing composer" && \
		curl -o composer.phar -fSL "https://github.com/composer/composer/releases/download/${COMPOSER_VERSION}/composer.phar"; \
		chmod +x ./composer.phar; \
    	mv ./composer.phar /usr/local/bin/composer

RUN	echo "Installing mooosh" && \
		# curl -o moosh.zip -fSL "https://moodle.org/plugins/download.php/21420/moosh_moodle38_2020042300.zip"; \
		# unzip moosh.zip -d /usr/src; \	
		# mkdir /usr/src/moosh; \
		curl -o moosh.tar.gz -fSL "https://github.com/tmuras/moosh/archive/${MOOSH_VERSION}.tar.gz"; \
		mkdir /usr/src/moosh; \
		tar -xf moosh.tar.gz -C /usr/src/moosh --strip 1; \
		composer install -d /usr/src/moosh; \
		ln -s /usr/src/moosh/moosh.php /usr/local/bin/moosh; \
		rm moosh.tar.gz


COPY moodle-config.php /usr/src/moodle/config.php
COPY docker-entrypoint.sh /usr/local/bin/

# Fix the original permissions of /tmp, the PHP default upload tmp dir.

RUN chmod 777 /tmp && chmod +t /tmp ;\
	chown -R www-data:www-data -R /usr/src/moodle
RUN echo "new test..ssaaas."
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]
