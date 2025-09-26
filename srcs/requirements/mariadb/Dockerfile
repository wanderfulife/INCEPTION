# Use the penultimate stable version of Debian as the base image.
FROM debian:bullseye

# Update the package list and install the MariaDB server package.
# -y automatically answers yes to any prompts.
RUN apt-get update && apt-get install -y mariadb-server

# Copy the database configuration script from the local 'tools' directory into the container.
COPY tools/configure-db.sh /usr/local/bin/configure-db.sh
# Make the script executable.
RUN chmod +x /usr/local/bin/configure-db.sh

# Expose the default MySQL/MariaDB port to allow other containers to connect.
EXPOSE 3306

# Set the command to run when the container starts.
# This script will initialize the database and then start the MariaDB daemon.
CMD ["/usr/local/bin/configure-db.sh"]
