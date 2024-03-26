## Nginx Configuration with Docker

This repository contains the necessary configuration to run an Nginx server with Docker using Docker Compose. Detailed instructions are provided for properly configuring the Nginx server, as well as for automatically generating SSL certificates using Let's Encrypt.

### Included Files:

1. **docker-compose.yml**: This file defines the services required to run the Nginx server along with Docker. It includes configuration for Nginx, Docker-gen (for dynamically generating Nginx configuration), and Let's Encrypt companion (for automatic SSL certificate management).

2. **nginx.tmpl**: This file is a template used by Docker-gen to dynamically generate Nginx configuration. It contains Nginx configuration directives that will be applied as containers start or stop.

3. **README.md**: This file contains detailed instructions on how to configure and run the Nginx server with Docker. It provides a step-by-step guide for initial setup and SSL certificate management.

### Usage Instructions:

1. **Initial Setup**:
   - Clone this repository to your local machine.
   - Ensure you have Docker and Docker Compose installed on your system.
   - Create an external Docker network named `nginx-proxy` by running the following command:
     ```
     docker network create nginx-proxy
     ```
   - Edit the `docker-compose.yml` file as needed for your specific configuration.

2. **SSL Certificate Generation**:
   - Before running the containers, ensure that the domain you wish to use is correctly pointing to your server's IP.
   - Run `docker-compose up -d` in the project directory to start the Docker services.
   - Let's Encrypt companion will automatically generate the required SSL certificates for your configured domain.

3. **Using Containers with Nginx**:
   - To use Nginx as a reverse proxy for other Docker services, simply add the appropriate labels to the containers you wish to expose through Nginx. Make sure to add the `VIRTUAL_HOST` label with the desired domain.
   - Example labels in other Docker containers:
     ```
     version: '3'
     services:
       app:
         image: image_name
         container_name: container_name
         labels:
           - "VIRTUAL_HOST=domain.com"
     ```

4. **SSL Certificate Management**:
   - Let's Encrypt companion will automatically renew SSL certificates before they expire.
   - To force renewal of a certificate, simply restart the Let's Encrypt companion container by running `docker-compose restart nginx-proxy-le`.

5. **Additional Customization**:
   - If you wish to further customize the Nginx configuration, you can edit the `nginx.tmpl` file to adjust Nginx directives according to your specific needs.

By following these instructions, you'll be able to quickly and easily set up and run an Nginx server with Docker, with support for automatic SSL certificates.
