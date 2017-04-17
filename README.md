# docker-lighttpd

**This project is not aimed at public consumption.
It exists to support the development of SICZ containers.**

Lighttpd web server running in the
[docker-baseimage-alpine](https://github.com/sicz/docker-baseimage-alpine)
container.

## Contents

This container only contains essential components:
- [docker-baseimage-alpine](https://github.com/sicz/docker-baseimage-alpine) as base system
- `ligttpd` as web server

## Getting started

These instructions will get you a copy of the project up and running on your
local machine for development and testing purposes. See deployment for notes
on how to deploy the project on a live system.

### Installing

Clone GitHub repository to your working directory:
```bash
git clone https://github.com/sicz/docker-baseimage-alpine
```

### Usage

Use command `make` to simplify Docker container development tasks:
```bash
make all        # Destroy running container, build new image, run container and show logs
make build      # Build new image
make rebuild    # Refresh Dockerfile and build new image
make run        # Run container
make stop       # Stop running container
make start      # Start stopped container
make restart    # Restart container
make status     # Show container status
make logs       # Show container logs
make logs-tail  # Connect to container logs
make shell      # Open shell in running container
make rm         # Destroy running container
```

`lighttpd` serving contents of it's `/var/www` directory and. All logs are
send to Docker console.

## Deployment

You can start with sample `docker-compose.yml` file:
```yaml
services:
  lighttpd:
    image: sicz/lighttpd:3.5
    ports:
      - 8080:8080
    volumes:
      - $PWD/www:/var/www
```

## Authors

* [Petr Řehoř](https://github.com/prehor) - Initial work.

See also the list of [contributors](https://github.com/sicz/docker-baseimage-alpine/contributors)
who participated in this project.

## License

This project is licensed under the Apache License, Version 2.0 - see the
[LICENSE](LICENSE) file for details.

<!---
## Acknowledgments

[*Hat tip to anyone who's code or inspiration was used*]
--->
