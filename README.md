# Inception

A system administration project using Docker to set up a small infrastructure composed of different services following specific rules.

## Project Overview

This project involves creating a multi-container Docker application with:
- **NGINX** - Web server with TLSv1.2/TLSv1.3
- **WordPress** - Content Management System with php-fpm
- **MariaDB** - Database server

Each service runs in a dedicated Docker container built from Alpine or Debian stable, with custom Dockerfiles.

## Architecture

```
┌─────────────────────────────────────────┐
│            Host Machine                  │
│  ┌───────────────────────────────────┐  │
│  │     Docker Network (Bridge)       │  │
│  │                                   │  │
│  │  ┌─────────┐  ┌──────────┐      │  │
│  │  │  NGINX  │  │WordPress │      │  │
│  │  │  :443   │──│  +PHP-FPM│      │  │
│  │  └─────────┘  │  :9000   │      │  │
│  │       │       └──────────┘      │  │
│  │       │            │             │  │
│  │       │       ┌──────────┐      │  │
│  │       └───────│ MariaDB  │      │  │
│  │               │  :3306   │      │  │
│  │               └──────────┘      │  │
│  └───────────────────────────────────┘  │
│                                         │
│  Volumes:                               │
│  • /home/user/data/wordpress            │
│  • /home/user/data/mariadb              │
└─────────────────────────────────────────┘
```

## Getting Started

### Prerequisites

- Docker
- Docker Compose
- Make (optional, for Makefile commands)

### Installation

1. **Clone the repository:**
   ```bash
   git clone git@github.com:patrixampm/inception.git
   cd inception
   ```

2. **Execute Make, creating files for volumes and building container network:**
   ```bash
   make
   cd srcs/
   ```

3. **SSL Certificate:**
Self-signed certificate generated with:
```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout user.42.fr.key \
    -out user.42.fr.crt \
    -subj "/C=ES/ST=<your_state>/L=<you_province>/O=42/OU=42/CN=user.42.fr"
mkdir /requirements/nginx/ssl
mv user.fr.key /requirements/nginx/ssl/
mv user.fr.crt /requirements/nginx/ssl/
```

4. **Configure environment variables:**
   
   Create a `.env` file in the `srcs/` directory with your credentials:
   ```bash
   # Database Configuration
   DB_NAME=wordpress
   DB_USER=wpuser
   DB_PASS=your_secure_password
   DB_ROOT=your_root_password
   
   # WordPress Configuration
   WP_DB_HOST=mariadb
   WP_URL=https://user.42.fr
   TITLE=My Inception Site
   DOMAIN_NAME=user.42.fr
   
   # WordPress Admin
   WP_ADMIN_USER=admin
   WP_ADMIN_PASS=admin_password
   WP_ADMIN_EMAIL=admin@example.com
   
   # WordPress User
   WP_USER=user
   WP_EMAIL=user@example.com
   WP_PASS=user_password
   ```

5. **Update `/etc/hosts`:**
   ```bash
   sudo nano /etc/hosts
   ```
   Add:
   ```
   127.0.0.1    user.42.fr
   ```

6. **Run containers:**
   ```bash
   docker-compose up
   ```

## Project Structure

```
inception/
├── Makefile
└── srcs/
    ├── docker-compose.yml
    ├── .env
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── db.sh
        │   └── .dockerignore
        ├── nginx/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── nginx.conf
        │   ├── ssl/
        │   │   ├── user.42.fr.crt
        │   │   └── user.42.fr.key
        │   └── .dockerignore
        └── wordpress/
            ├── Dockerfile
            ├── conf/
            │   └── www.conf
            ├── tools/
            │   └── wp.sh
            └── .dockerignore
```

## Services

### NGINX
- Listens on port **443** (HTTPS only)
- Uses **TLSv1.2** and **TLSv1.3**
- Self-signed SSL certificate
- Acts as reverse proxy to WordPress

### WordPress + PHP-FPM
- Runs on port **9000** (FastCGI)
- Connects to MariaDB
- Installed and configured via WP-CLI
- Persistent storage in volume

### MariaDB
- Database server on port **3306**
- Persistent storage in volume
- Configured at runtime with environment variables

## Docker Commands

### Start the project:
```bash
docker-compose up -d
```

### Stop the project:
```bash
docker-compose down
```

### Rebuild containers:
```bash
docker-compose up --build
```

### View logs:
```bash
docker-compose logs -f
```

### Clean everything (including volumes):
```bash
docker-compose down -v
docker system prune -a
```

### Check container status:
```bash
docker ps
docker stats
```

## Access

Once running, access your WordPress site at:
- **https://user.42.fr**

You'll see a browser warning about the self-signed certificate - this is expected. Click "Advanced" and "Proceed" to continue.

## Configuration Details

### Volumes
- **WordPress files**: `/home/$USER/data/wordpress`
- **Database files**: `/home/$USER/data/mariadb`

Data persists even when containers are stopped or removed.

### Network
All services communicate through a custom Docker bridge network named `inception`.

## Troubleshooting

### Container won't start
```bash
docker-compose logs [service_name]
```

### Permission issues with volumes
```bash
sudo chown -R $USER:$USER /home/$USER/data
```

### Reset everything
```bash
docker-compose down -v
sudo rm -rf /home/$USER/data/wordpress/*
sudo rm -rf /home/$USER/data/mariadb/*
docker-compose up --build
```

### MariaDB connection issues
Check that WordPress is waiting for MariaDB to be healthy (healthcheck in docker-compose.yml).
