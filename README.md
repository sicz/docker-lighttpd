# docker-lighttpd

[![CircleCI Status Badge](https://circleci.com/gh/sicz/docker-lighttpd.svg?style=shield&circle-token=e2810a9421a2eaf33f8c620d67876f7a86f6e784)](https://circleci.com/gh/sicz/docker-lighttpd)

**This project is not aimed at public consumption.
It exists to serve as a single endpoint for SICZ containers.**

A lighttpd web server based on [sicz/baseimage-alpine](https://github.com/sicz/docker-baseimage).

## Contents

This container only contains essential components:
* [sicz/baseimage-alpine](https://github.com/sicz/docker-baseimage)
  as a base image.
* [lighttpd](https://www.lighttpd.net) provides a web server.

## Getting started

These instructions will get you a copy of the project up and running on your
local machine for development and testing purposes. See deployment for notes
on how to deploy the project on a live system.

### Installing

Clone the GitHub repository into your working directory:
```bash
git clone https://github.com/sicz/docker-lighttpd
```

### Usage

Use the command `make` in the project directory:
```bash
make all                # Build a new image and run the tests
make ci                 # Build a new image and run the tests
make build              # Build a new image
make rebuild            # Build a new image without using the Docker layer caching
make config-file        # Display the configuration file for the current configuration
make vars               # Display the make variables for the current configuration
make up                 # Remove the containers and then run them fresh
make create             # Create the containers
make start              # Start the containers
make stop               # Stop the containers
make restart            # Restart the containers
make rm                 # Remove the containers
make wait               # Wait for the start of the containers
make ps                 # Display running containers
make logs               # Display the container logs
make logs-tail          # Follow the container logs
make shell              # Run the shell in the container
make test               # Run the tests
make test-shell         # Run the shell in the test container
make clean              # Remove all containers and work files
make docker-pull        # Pull all images from the Docker Registry
make docker-pull-baseimage    # Pull the base image from the Docker Registry
make docker-pull-dependencies # Pull the project image dependencies from the Docker Registry
make docker-pull-image        # Pull the project image from the Docker Registry
make docker-pull-testimage    # Pull the test image from the Docker Registry
make docker-push        # Push the project image into the Docker Registry
```

`lighttpd` with the default configuration listens on TCP ports 80 and 443,
serves the contents of it's `/var/www` directory and sends all logs to
the Docker console.

## Deployment

You can start with this sample `docker-compose.yml` file:
```yaml
services:
  lighttpd:
    image: sicz/lighttpd
    ports:
      - 8080:80
      - 8443:443
    volumes:
      - ./secrets:/run/secrets
      - ./config/server.conf:/etc/lighttpd/server.conf
      - ./www/:/var/www
```

## Authors

* [Petr Řehoř](https://github.com/prehor) - Initial work.

See also the list of
[contributors](https://github.com/sicz/docker-lighttpd/contributors)
who participated in this project.

## License

This project is licensed under the Apache License, Version 2.0 - see the
[LICENSE](LICENSE) file for details.
