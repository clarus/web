FROM ubuntu
MAINTAINER Guillaume Claret

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y git m4
RUN apt-get install -y nginx curl
RUN apt-get install -y gcc make ruby-dev
RUN apt-get install -y texlive-latex-base
RUN apt-get install -y texlive-latex-extra
RUN apt-get install -y texlive-fonts-recommended
RUN apt-get install -y texlive-fonts-extra
RUN apt-get install -y texlive-lang-french texlive-math-extra
RUN apt-get install -y inkscape
RUN apt-get install -y ocaml-nox aspcud
RUN gem install redcarpet

# Add a user clarus.
RUN useradd --create-home clarus
USER clarus
ENV HOME /home/clarus

# # Add the projects contents.
# WORKDIR /home/clarus
# RUN mkdir projects
# WORKDIR projects
# ADD make_reports.rb /home/clarus/projects/make_reports.rb
# RUN ruby make_reports.rb

# OPAM
WORKDIR /home/clarus
RUN curl -L https://github.com/ocaml/opam/archive/1.2.0.tar.gz |tar -xz
WORKDIR opam-1.2.0
RUN ./configure && make lib-ext && make
USER root
RUN make install
USER clarus
RUN opam init && opam switch 4.02.1
ENV OPAMJOBS 2

# Coq
RUN opam install -y coq

# Coq repositories
RUN opam repo add coq-stable https://github.com/coq/repo-stable.git && opam repo add coq-unstable https://github.com/coq/repo-unstable.git

# Pluto
RUN opam install -y coq:concurrency:pluto

# Hack: we force to rebuild the container here.
# ADD force_update /

# Add the main website.
WORKDIR /home/clarus
RUN curl -L https://bitbucket.org/guillaumeclaret/www/get/default.tar.bz2 |tar -xj
RUN mv guillaumeclaret-www-* www
WORKDIR www
RUN ruby make.rb
RUN cd coq.io && ruby make.rb && cd ..

# Add the blog.
RUN curl -L https://github.com/clarus/coq-blog/archive/master.tar.gz |tar -xz
RUN mv coq-blog-master coq-blog
WORKDIR coq-blog
RUN curl -L https://github.com/clarus/coq-red-css/releases/download/coq-blog.1.0.2/style.min.css >static/style.min.css
RUN make

# Set the Nginx configuration.
USER root
WORKDIR /etc/nginx
RUN rm sites-enabled/default
ADD all /etc/nginx/sites-available/all
RUN ln -rs sites-available/all sites-enabled/
ADD cache.conf /etc/nginx/cache.conf

# Run the servers.
EXPOSE 80
WORKDIR /
ADD run.rb /run.rb
CMD ["ruby", "run.rb"]
# CMD ["nginx", "-g", "daemon off;"]
