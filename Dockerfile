FROM ubuntu:14.10
MAINTAINER Guillaume Claret

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y git mercurial
RUN apt-get install -y ruby
RUN apt-get install -y nginx
RUN apt-get install -y make

# Add a user clarus.
RUN useradd --create-home clarus
USER clarus
ENV HOME /home/clarus

# Add the websites.
USER clarus
WORKDIR /home/clarus
RUN hg clone https://bitbucket.org/guillaumeclaret/www
WORKDIR www
RUN ruby make.rb

# Add the blog.
RUN git clone https://github.com/clarus/light-blog blog
WORKDIR blog
RUN git clone https://github.com/clarus/blog-posts posts
RUN TITLE=Clarus DISQU=login make

# Set the Nginx configuration.
USER root
WORKDIR /etc/nginx
RUN rm sites-enabled/default
ADD nginx.conf /etc/nginx/sites-available/all
RUN ln -rs sites-available/all sites-enabled/

# Run Nginx.
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
