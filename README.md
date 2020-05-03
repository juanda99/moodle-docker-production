# moodle-docker-production: Docker Containers for Moodle

This repository contains Docker configuration aimed to provide a good starting point to install moodle in production using docker.


## Features
* Database servers: MySQL (more to come)
* Last supported PHP version
* Zero-configuration approach
* All php-extensions (thanks to [moodlehq](https://github.com/moodlehq/moodle-php-apache))


## Next Features
* Crontab configuration (in progress)
* Auto backup (in progress)


## Prerequisites
* [Docker](https://docs.docker.com) and [Docker Compose](https://docs.docker.com/compose/) installed

## Quick start


```
docker-compose up -d
```

Open browser webpage: http://localhost (be patient)


## Configuration

* Configure your moodle installation using an env file (modify default values if needed)

## Activate https

- Not tested! Using [letsEncrypt](https://letsencrypt.org/)

```
cp docker-compose.override_prod.yml docker-compose.override.yml
docker-compose up -d
```

## Contributions

Are extremely welcome!
