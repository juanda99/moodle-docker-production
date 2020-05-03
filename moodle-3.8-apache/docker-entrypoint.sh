#!/bin/bash
set -euo pipefail

# install only if executed without CMD parameter

if [[ "$1" == apache2* ]] || [ "$1" == php-fpm ]; then
	if [ "$(id -u)" = '0' ]; then
		case "$1" in
			apache2*)
				user="${APACHE_RUN_USER:-www-data}"
				group="${APACHE_RUN_GROUP:-www-data}"

				# strip off any '#' symbol ('#1000' is valid syntax for Apache)
				pound='#'
				user="${user#$pound}"
				group="${group#$pound}"
				;;
			*) # php-fpm
				user='www-data'
				group='www-data'
				;;
		esac
	else
		user="$(id -u)"
		group="$(id -g)"
	fi

	if [ ! -e config.php ]; then
		# if the directory exists and Moodle doesn't appear to be installed AND the permissions of it are root:root, let's chown it (likely a Docker-created directory)
		if [ "$(id -u)" = '0' ] && [ "$(stat -c '%u:%g' .)" = '0:0' ]; then
			chown "$user:$group" .
		fi

		echo >&2 "Moodle not found in $PWD - copying now..."
		if [ -n "$(ls -A)" ]; then
			echo >&2 "WARNING: $PWD is not empty! (copying anyhow)"
		fi
		sourceTarArgs=(
			--create
			--file -
			--directory /usr/src/moodle
			--owner "$user" --group "$group"
		)
		targetTarArgs=(
			--extract
			--file -
		)
		if [ "$user" != '0' ]; then
			# avoid "tar: .: Cannot utime: Operation not permitted" and "tar: .: Cannot change mode to rwxr-xr-x: Operation not permitted"
			targetTarArgs+=( --no-overwrite-dir )
		fi
		tar "${sourceTarArgs[@]}" . | tar "${targetTarArgs[@]}"
		echo >&2 "Complete! Moodle has been successfully copied to $PWD"
		# if [ ! -e .htaccess ]; then
		# 	# NOTE: The "Indexes" option is disabled in the php:apache base image
		# 	cat > .htaccess <<-'EOF'
		# 		# BEGIN WordPress
		# 		<IfModule mod_rewrite.c>
		# 		RewriteEngine On
		# 		RewriteBase /
		# 		RewriteRule ^index\.php$ - [L]
		# 		RewriteCond %{REQUEST_FILENAME} !-f
		# 		RewriteCond %{REQUEST_FILENAME} !-d
		# 		RewriteRule . /index.php [L]
		# 		</IfModule>
		# 		# END WordPress
		# 	EOF
		# 	chown "$user:$group" .htaccess
		# fi
	fi
fi

exec "$@"