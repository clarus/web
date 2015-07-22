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
RUN apt-get install -y ocaml-nox unzip aspcud
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
RUN ruby make_reports.rb

# Install OPAM.
RUN curl -L https://github.com/ocaml/opam/archive/1.2.2.tar.gz |tar -xz
WORKDIR opam-1.2.2
RUN ./configure && make lib-ext && make
USER root
RUN make install
USER clarus
RUN opam init && opam repo add coq-released https://coq.inria.fr/opam/released
RUN opam install -y coq:io:system:ocaml

# Hack: we force to rebuild the container here.
ADD force_update /

# Add the main website.
WORKDIR /home/clarus
RUN curl -L https://bitbucket.org/guillaumeclaret/www/get/default.tar.bz2 |tar -xj
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
RUN curl -L https://github.com/coq-io/opam-website/archive/1.3.1.tar.gz |tar -xz
RUN mv opam-website-* opam-website
WORKDIR opam-website/extraction
RUN curl -L https://github.com/coq-io/opam-website/releases/download/1.3.1/opamWebsite.ml >opamWebsite.ml
RUN curl -L https://github.com/clarus/coq-red-css/releases/download/coq-blog.1.0.2/style.min.css >html/style.min.css
RUN eval `opam config env` make && opam update && ./opamWebsite.native && cp -R html ../../coq-io/output/opam
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
CMD ["nginx", "-g", "daemon off;"]
