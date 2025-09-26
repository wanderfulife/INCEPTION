# Inception Project

This project, as part of the 42 curriculum, involves setting up a complete web server environment using Docker. The goal is to containerize several services and orchestrate them using `docker-compose`.

## Table of Contents
- [Architecture](#architecture)
- [Technology Stack](#technology-stack)
- [Prerequisites](#prerequisites)
- [Setup and Configuration](#setup-and-configuration)
- [How to Run](#how-to-run)
- [Makefile Commands](#makefile-commands)
- [Directory Structure](#directory-structure)
- [VM for Evaluation](#vm-for-evaluation)

## Architecture

The infrastructure consists of three main services running in separate containers:

1.  **NGINX:** The web server and entry point of the application. It serves the WordPress site and handles SSL/TLS encryption (TLSv1.2 and TLSv1.3). All traffic comes through port 443.
2.  **WordPress:** The Content Management System (CMS). It runs on PHP-FPM and communicates with the NGINX server over a private Docker network.
3.  **MariaDB:** The database for WordPress. It stores all site content, user data, etc., and is only accessible from the WordPress container.

All services are connected via a custom bridge network called `inception-network`, ensuring they are isolated from the host machine except for the ports we explicitly expose.

## Technology Stack

- **Containerization:** Docker & Docker Compose
- **Services:**
    - Web Server: NGINX
    - CMS: WordPress with PHP-FPM
    - Database: MariaDB
- **Base OS (in containers):** Debian Bullseye
- **Orchestration:** `make`

## Prerequisites

Before you begin, ensure you have the following installed on your host machine:
- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

## Setup and Configuration

1.  **Environment Variables:**
    The project uses a `.env` file located in the `srcs` directory to manage all secrets and configuration variables. Before running the project, you must have a `.env` file with the correct values.

    *Example `srcs/.env` file:*
    ```env
    # --- Domain Configuration ---
    DOMAIN_NAME=jowander.42.fr

    # --- MariaDB Database Configuration ---
    MYSQL_ROOT_PASSWORD=root_password_strong
    MYSQL_DATABASE=wordpress
    MYSQL_USER=wp_user
    MYSQL_PASSWORD=wp_password_strong

    # --- WordPress Administrator User ---
    WP_ADMIN_USER=jowander
    WP_ADMIN_PASSWORD=admin_password_strong
    WP_ADMIN_EMAIL=jowander@student.42.fr

    # --- Second WordPress User ---
    WP_USER_LOGIN=user2
    WP_USER_PASSWORD=user2_password_strong
    WP_USER_EMAIL=user2@example.com
    ```

2.  **Host File Configuration:**
    To access the WordPress site using its domain name, you must add the following line to your `/etc/hosts` file (on Linux/macOS) or `C:\Windows\System32\drivers\etc\hosts` (on Windows):
    ```
    127.0.0.1 jowander.42.fr
    ```
    Replace `jowander.42.fr` if you have changed the `DOMAIN_NAME` in the `.env` file.

## How to Run

1.  **Build and Start the Services:**
    Navigate to the root of the project and run the `make` command:
    ```sh
    make
    ```
    This will build the Docker images and start all the services in detached mode.

2.  **Access the Website:**
    Open your web browser and navigate to `https://jowander.42.fr`.
    You will see a security warning because the project uses a self-signed SSL certificate. You can safely accept the warning and proceed to the site.

3.  **WordPress Credentials:**
    - **Administrator:** Use the `WP_ADMIN_USER` and `WP_ADMIN_PASSWORD` from your `.env` file to log in.
    - **Second User:** A non-admin user is also created with the `WP_USER_LOGIN` and `WP_USER_PASSWORD` credentials.

## Makefile Commands

The `Makefile` provides several commands to manage the application lifecycle:

- `make` or `make up`: Builds images if they don't exist and starts all containers.
- `make down`: Stops and removes all running containers.
- `make clean`: A more thorough cleanup. It stops containers, removes them, deletes the volumes (all database and WordPress data will be lost!), and removes the Docker images.
- `make re`: A shortcut for `make clean` followed by `make up`.

## Directory Structure

```
.
├── Makefile          # Main script to build, run, and clean the project.
├── README.md         # This file.
├── data/             # Host directory for persistent data.
│   ├── mariadb/      # Stores the MariaDB database files.
│   └── wordpress/    # Stores the WordPress core files, themes, and plugins.
└── srcs/             # Contains all source and configuration files.
    ├── .env          # Environment variables (passwords, domain name, etc.).
    ├── docker-compose.yml # Defines all services, networks, and volumes.
    └── requirements/   # Contains the Dockerfiles and configs for each service.
        ├── mariadb/
        ├── nginx/
        └── wordpress/
```

## VM for Evaluation

For project evaluation, it is required to submit a portable Virtual Machine.

1.  **Setup:** Install a hypervisor (like VirtualBox), create a Debian/Ubuntu VM, install Docker/Git, and get the project running inside it.
2.  **Export:** Shut down the VM and use the `File -> Export Appliance...` option in VirtualBox to create a single `.ova` file.
3.  **Submission:** This `.ova` file is what you place on a USB key for evaluation.
