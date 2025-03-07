# Python Web App Test Container

This is a Docker container designed as a base image for testing Python-based web
applications. It includes various components commonly needed for such applications,
including a stable version of Chrome, MariaDB, NGINX, uWSGI, and essential development
tools.

## Key Features

- **Python X.Y**: Specific version of Python this container is based on.
- **Google Chrome (Stable)**: Installed for browser automation testing.
- **MariaDB**: A drop-in replacement for MySQL, included with root password set to 'root'.
- **uWSGI**: A server for Python web applications.
- **NGINX**: A high-performance web server and reverse proxy server.
- **Development Tools**: Includes Git, Vim, and Cron for development and testing purposes.

## Installation

1. Clone the repository:

```bash
git clone https://your-repository.git
```

2. Build the Docker image:

```bash
docker build -t your-image-name:tag .
```

Replace `your-image-name` with the name of your image and `tag` with a version tag (e.g.,
`latest` or `1.0`).

## Usage

This image will likely be used as the FROM image in a new Dockerfile that creates an
image specific to your own test scenario.

To run the container as-is, use the following command:

```bash
docker run --name python-web-test -p 80:80 -d your-image-name:tag
```

This will start a container named `python-web-test`, mapping port 80 of the container to
port 80 on your host machine.

### Connecting to MariaDB

MariaDB is pre-installed with the root password set to 'root'. You can connect to it using:

```bash
mysql -u root -p
```

Enter 'root' when prompted for the password. The database server will be running on port
3306 inside the container.

### Using Chrome

Google Chrome is installed and available in the container. You can use tools like Selenium
or Puppeteer for browser automation testing.

### Accessing NGINX

NGINX is pre-installed and configured. You can access it via port 80 on your host machine.
To modify the NGINX configuration, you can edit the files inside the container.

## Notes

- **Security**: The MariaDB root password is set to 'root' for convenience in testing
environments. For production use, consider changing this password and adjusting permissions.
- **Chrome Installation**: The Chrome installation method used here may not be the most
secure or reliable. Consider using official Debian packages or alternative methods for
production use.  We used this method because we needed a specific version of Chrome that
is stable for testing.  The more recent 134.* version is not stable at this time.
- **Customization**: This image is intended as a base. You can further customize it by
adding specific dependencies, environment variables, or configurations required by your
project.

