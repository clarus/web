FROM ubuntu:14.10
MAINTAINER Guillaume Claret

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y git mercurial
RUN apt-get install -y ruby
RUN apt-get install -y nginx

# Add a user clarus.
RUN useradd --create-home clarus
USER clarus
ENV HOME /home/clarus

# Add the websites.
USER clarus
WORKDIR /home/clarus
RUN echo 1
RUN hg clone https://bitbucket.org/guillaumeclaret/www guillaume
WORKDIR guillaume
RUN ruby make.rb

# Set the Nginx configuration.
USER root
WORKDIR /etc/nginx
RUN rm sites-enabled/default
ADD nginx.conf /etc/nginx/sites-available/all
RUN ln -rs sites-available/all sites-enabled/

# Run Nginx.
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
