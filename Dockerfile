FROM ubuntu
MAINTAINER Guillaume Claret

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y nginx curl
RUN apt-get install -y gcc make ruby-dev
RUN apt-get install -y texlive-latex-extra texlive-fonts-recommended
RUN gem install redcarpet

# Set the Nginx configuration.
WORKDIR /etc/nginx
RUN rm sites-enabled/default
ADD all /etc/nginx/sites-available/all
RUN ln -rs sites-available/all sites-enabled/
ADD cache.conf /etc/nginx/cache.conf

# Add a user clarus.
RUN useradd --create-home clarus
USER clarus
ENV HOME /home/clarus

# Hack: we force to rebuild the container here.
ADD force_update /

# Add the main website.
USER clarus
WORKDIR /home/clarus
RUN curl -L https://bitbucket.org/guillaumeclaret/www/get/default.tar.bz2 |tar -xj
RUN mv guillaumeclaret-www-* www
WORKDIR www
RUN ruby make.rb

# Add the blog.
RUN curl -L https://github.com/clarus/coq-blog/archive/master.tar.gz |tar -xz
RUN mv coq-blog-master coq-blog
WORKDIR coq-blog
RUN curl -L https://github.com/clarus/coq-red-css/releases/download/coq-blog.1.0.2/style.min.css >static/style.min.css
RUN make

# Add the projects contents.
WORKDIR /home/clarus
RUN mkdir projects

WORKDIR /home/clarus/projects
RUN curl -L https://bitbucket.org/guillaumeclaret/cv-english/get/default.tar.bz2 |tar -xj
RUN mv guillaumeclaret-cv-english-* cv-english
WORKDIR cv-english
RUN TERM=xterm make

WORKDIR /home/clarus/projects
RUN curl -L https://bitbucket.org/guillaumeclaret/cv-french/get/default.tar.bz2 |tar -xj
RUN mv guillaumeclaret-cv-french-* cv-french
WORKDIR cv-french
RUN TERM=xterm make

# Run Nginx.
USER root
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
