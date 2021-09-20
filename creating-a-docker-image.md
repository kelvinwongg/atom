# Creating a docker image

## The Youtube tutorial
1. OS
2. Update apt repo
3. Install apt dependencies
4. Install Python with pip
5. Copy source code to /opt folder
6. Run the web server using "flask" command

## To run apache with docker without a Dockerfile
`docker run -dit --name apache -p 8080:80 -v "$PWD":/usr/local/apache2/htdocs/ httpd:2.4-alpine`