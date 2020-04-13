# ft_server
42/Codam ft_server, an introduction to Docker
## Description
In ft_server, we set up a web server through Docker, using Nginx and Debian Buster. The server must run Wordpress, phpMyAdmin, and an SQL database. Scripts are used to create a fully-configured server at launch time. 
## Commands
```
# Build image
docker image build -t ft_server .

# Run image with interactive and pseudo-terminal flags
docker run -p 80:80 -p 443:443 -it ft_server

# Cleaning
docker system prune -a
docker image prune -a

# Stop container
docker container stop ft_server

# Check running containers
docker ps
```
