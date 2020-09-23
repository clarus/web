FROM ubuntu:14.04
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
RUN apt-get install -y inkscape sudo
RUN apt-get install -y ocaml-nox bzip2 unzip aspcud pkg-config
RUN gem install redcarpet

# Add a user clarus.
RUN useradd --create-home clarus
USER clarus
ENV HOME /home/clarus

# Add the projects contents.
WORKDIR /home/clarus
RUN mkdir projects
WORKDIR projects
ADD make_reports.rb /home/clarus/projects/make_reports.rb
#RUN ruby make_reports.rb

# Install OCaml.
WORKDIR /home/clarus
RUN curl -L https://github.com/ocaml/ocaml/archive/4.02.3.tar.gz |tar -xz
WORKDIR ocaml-4.02.3
RUN ./configure && make world.opt
USER root
RUN make install
USER clarus

# Install OPAM.
WORKDIR /home/clarus
RUN curl -L https://github.com/ocaml/opam/releases/download/2.0.4/opam-full-2.0.4.tar.gz |tar -xz
WORKDIR opam-full-2.0.4
RUN ./configure && make lib-ext && make
USER root
RUN make install
USER clarus
RUN opam init -n --disable-sandboxing && opam repo add coq-released https://coq.inria.fr/opam/released
RUN opam install -y coq-io-system-ocaml.2.3.0

# Hack: we force to rebuild the container here.
ADD force_update /

# Add the main website.
WORKDIR /home/clarus
RUN curl -L https://bitbucket.org/guillaumeclaret/www/get/master.tar.gz |tar -xz
RUN mv guillaumeclaret-www-* www
WORKDIR www
RUN ruby make.rb
RUN cd coq.io && ruby make.rb

# Add the blog.
RUN curl -L https://github.com/clarus/coq-blog/archive/master.tar.gz |tar -xz
RUN mv coq-blog-* coq-blog
WORKDIR coq-blog
RUN curl -L https://github.com/clarus/coq-red-css/releases/download/coq-blog.1.0.2/style.min.css >static/style.min.css
RUN make
WORKDIR ..

# Add coq.io.
RUN curl -L https://github.com/coq-io/website/archive/master.tar.gz |tar -xz
RUN mv website-* coq-io
WORKDIR coq-io
RUN make
WORKDIR ..

# Add OpamWebsite.
RUN curl -L https://github.com/coq-io/opam-website/archive/1.6.1.tar.gz |tar -xz
RUN mv opam-website-* opam-website
WORKDIR opam-website/extraction
RUN curl -L https://github.com/coq-io/opam-website/releases/download/1.6.1/opamWebsite.ml >opamWebsite.ml
RUN curl -L https://github.com/clarus/coq-red-css/releases/download/coq-blog.1.0.2/style.min.css >html/style.min.css
ADD opam_website.sh /home/clarus/
RUN /home/clarus/opam_website.sh
WORKDIR ../..

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
CMD while true; do sleep 12h; sudo -u clarus /home/clarus/opam_website.sh; done & nginx -g "daemon off;"
