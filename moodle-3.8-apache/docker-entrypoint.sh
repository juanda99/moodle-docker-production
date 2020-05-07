#!/bin/bash
set -euo pipefail
declare MOODLE_DATA=/var/www/moodledata

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
	if [ ! -d $MOODLE_DATA ]; then
		mkdir $MOODLE_DATA
		chown -R "$user:$group" $MOODLE_DATA
		echo >&2 "Moodle Data directory not found. Created!"
	else
		echo >&2 "Moodle Data directory found"
		# if the directory exists AND the permissions of it are root:root, let's chown it (likely a Docker-created directory)
		if [ "$(id -u)" = '0' ] && [ "$(stat -c '%u:%g' $MOODLE_DATA)" = '0:0' ]; then
		    echo >&2 "Changed permissions to Moodle Data directory"
			chown -R "$user:$group" $MOODLE_DATA
		fi
	fi


	if [ ! -e config.php ]; then


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
		echo >&2 "Starting Moodle Installation"

		# check if database is already installed 
		echo "Does it execute? 3"
		databaseCode=$(php $PWD/admin/cli/check_database_schema.php)
		echo "Does it execute?"
		if [ databaseCode -eq 2 ]; then
			echo >&2 "Installing database..."
			php $PWD/admin/cli/install_database.php --lang="es" --adminuser="root" --adminpass="password" --adminemail="juandacorreo@gmail.com" --agree-license --fullname="Moodle prueba" --shortname="prueba"
		elif [ databaseCode -eq 0 ]; then
			echo >&2 "Moodle Database found!"
		else
			echo >&2 "Could not install Moodle Database due to above errors!"
		fi
	fi
fi

exec "$@"