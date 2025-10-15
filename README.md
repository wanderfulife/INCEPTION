# Inception - 42 Project

## Overview

This project implements a complete web infrastructure using Docker containers. It includes:
- **MariaDB**: Database server
- **WordPress**: Content management system with PHP-FPM
- **NGINX**: Web server with TLS support

## VM Requirements

Before starting, ensure your virtual machine has:
- Docker installed
- Docker Compose installed
- At least 2GB of RAM
- Sufficient disk space for container images

## Prerequisites

Before running the project, you need to:
1. Install Docker and Docker Compose on your VM
2. Ensure your user has Docker permissions (may need to add to docker group)
3. Set up the necessary ports (specifically port 443)

### Installing Docker and Docker Compose

```bash
# Update package index
sudo apt update

# Install required packages
sudo apt install apt-transport-https ca-certificates curl software-properties-common

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add your user to the docker group
sudo usermod -aG docker $USER
```

## Setup Instructions

### 1. Domain Configuration

To access the WordPress site, add the following entry to your VM's `/etc/hosts` file:

```bash
# Add this line to your /etc/hosts file
127.0.0.1 jowander.42.fr
```

### 2. Data Directory Setup

The Makefile automatically creates and sets up the required data directories with proper permissions. When you run `make all`, the following happens automatically:
- Creates `$HOME/data/mariadb` and `$HOME/data/wordpress` directories
- Sets proper ownership for MariaDB and WordPress users

## Usage with Makefile

The project includes a Makefile with various commands:

### Basic Commands
- `make all` - Prepare directories and start the services
- `make setup` - Create necessary directories
- `make start` - Start the containers in background
- `make stop` - Stop all containers
- `make status` - Show current container status
- `make logs` - View container logs in real-time
- `make clean` - Stop containers and remove them
- `make fclean` - Perform clean and remove data directories
- `make re` - Clean everything and restart from scratch

## Architecture

The project consists of three main services:

### MariaDB Container
- Based on Debian Bookworm
- Contains MariaDB server with custom configuration
- Configuration includes datadir, socket, bind address, port, and user settings
- Contains initialization script (`mariadb_init.sh`) for setting up database
- Exposes port 3306 for database connections

### Nginx Container
- Based on Debian Bookworm
- Contains Nginx web server with SSL/TLS support
- Includes self-signed SSL certificate generation
- Configured for HTTPS with TLSv1.2 and TLSv1.3 protocols
- Serves WordPress files with PHP processing via FastCGI
- Reverse proxies PHP requests to WordPress container on port 9000

### WordPress Container
- Based on Debian Bookworm
- Contains PHP 8.2 with FPM and MySQL extensions
- Installs WP-CLI for command-line WordPress management
- Downloads and configures WordPress in French
- Includes PHP-FPM configuration with process management
- Contains initialization script (`wordpress_init.sh`) for WordPress setup

## Security Notes

- All passwords are stored in the `.env` file
- SSL certificate is self-signed (for educational purposes)
- The project uses bind mounts for persistent data storage
- Only port 443 is exposed to the host system

## Project Structure

- `Makefile` - Build and orchestration commands
- `srcs/` - Main source directory containing docker-compose.yml and requirements
- `srcs/requirements/` - Contains Dockerfiles for each service
  - `mariadb/` - MariaDB container files
  - `nginx/` - Nginx container files
  - `wordpress/` - WordPress container files
- `srcs/.env` - Environment variables for the containers
- `$HOME/data/` - Persistent data storage (MariaDB and WordPress files)

## Troubleshooting

### Common Issues

1. **Permission errors with data directories**:
   ```bash
   sudo chown -R 999:999 $HOME/data/mariadb
   sudo chown -R 33:33 $HOME/data/wordpress  # assuming www-data has uid/gid 33
   ```

2. **Docker permission denied**:
   ```bash
   # Log out and log back in to apply group changes
   # Or restart the Docker daemon:
   sudo systemctl restart docker
   ```

3. **Port conflicts**:
   - Ensure port 443 is available
   - Check with: `sudo netstat -tulpn | grep :443`

4. **SSL Certificate Issues**:
   - The site uses a self-signed certificate
   - You'll need to accept security exceptions in your browser

## Stopping the Project

Always stop the project properly before shutting down your VM:

```bash
make stop
```

This ensures data integrity and proper container shutdown.

## Project Status

After starting, you can access your WordPress site at:
- `https://jowander.42.fr` (using HTTPS due to TLS configuration)
# INCEPTION
