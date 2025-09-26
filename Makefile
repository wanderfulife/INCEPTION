# Specifies that these targets are not actual files.
# This prevents `make` from getting confused if a file with the same name as a target exists.
.PHONY: all up down clean

# The default command that runs when you just type `make`.
# It depends on the `up` target.
all: up

# Builds the Docker images and starts the services in detached mode.
up:
	# -f specifies the path to the docker-compose file.
	# --build forces the rebuilding of images from the Dockerfiles.
	# -d runs the containers in the background (detached mode).
	docker-compose -f srcs/docker-compose.yml up --build -d

# Stops and removes the containers.
down:
	docker-compose -f srcs/docker-compose.yml down

# Stops and removes containers, volumes, and images. Also cleans data directories.
clean:
	# -v removes the named volumes (db-data, wp-data).
	# --rmi all removes all images used by the services.
	docker-compose -f srcs/docker-compose.yml down -v --rmi all
	# Deletes the contents of the local data directories to ensure a fresh start.
	rm -rf data/mariadb/* data/wordpress/*
