FROM ubuntu:14.10
MAINTAINER Guillaume Claret

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y git mercurial
RUN apt-get install -y nginx curl
RUN apt-get install -y gcc make ruby-dev
RUN gem install redcarpet

# Set the Nginx configuration.
WORKDIR /etc/nginx
RUN rm sites-enabled/default
ADD nginx.conf /etc/nginx/sites-available/all
RUN ln -rs sites-available/all sites-enabled/

# Add a user clarus.
RUN useradd --create-home clarus
USER clarus
ENV HOME /home/clarus

# Hack: we force to rebuild the container here.
ADD force_update /

# Add the websites.
USER clarus
WORKDIR /home/clarus
RUN hg clone https://bitbucket.org/guillaumeclaret/www
WORKDIR www
RUN ruby make.rb

# Add the blog.
RUN git clone https://github.com/clarus/coq-blog coq-blog
WORKDIR coq-blog
RUN curl -L https://github.com/clarus/coq-red-css/releases/download/1.0.0/style.min.css >static/style.min.css
RUN make

# Run Nginx.
USER root
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
