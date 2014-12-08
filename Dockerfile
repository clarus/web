FROM ubuntu
MAINTAINER Guillaume Claret

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y nginx curl
RUN apt-get install -y gcc make ruby-dev
RUN apt-get install -y texlive-latex-base
RUN apt-get install -y texlive-latex-extra
RUN apt-get install -y texlive-fonts-recommended
RUN apt-get install -y texlive-lang-french texlive-math-extra
RUN apt-get install -y inkscape
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
# ADD force_update /

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
WORKDIR projects

RUN curl -L https://bitbucket.org/guillaumeclaret/cv-english/get/default.tar.bz2 |tar -xj
RUN mv guillaumeclaret-cv-english-* cv-english
WORKDIR cv-english
RUN TERM=xterm make
WORKDIR ..

RUN curl -L https://bitbucket.org/guillaumeclaret/cv-french/get/default.tar.bz2 |tar -xj
RUN mv guillaumeclaret-cv-french-* cv-french
WORKDIR cv-french
RUN TERM=xterm make
WORKDIR ..

RUN curl -L https://bitbucket.org/guillaumeclaret/m2-reports-hoare/get/default.tar.bz2 |tar -xj
RUN mv guillaumeclaret-m2-reports-hoare-* m2-reports-hoare
WORKDIR m2-reports-hoare
RUN TERM=xterm make
WORKDIR ..

RUN curl -L https://bitbucket.org/guillaumeclaret/m2-reports-main/get/default.tar.bz2 |tar -xj
RUN mv guillaumeclaret-m2-reports-main-* m2-reports-main
WORKDIR m2-reports-main
RUN TERM=xterm make
WORKDIR ..

RUN curl -L https://bitbucket.org/guillaumeclaret/m2-reports-slides/get/default.tar.bz2 |tar -xj
RUN mv guillaumeclaret-m2-reports-slides-* m2-reports-slides
WORKDIR m2-reports-slides
RUN TERM=xterm make
WORKDIR ..

RUN curl -L https://bitbucket.org/guillaumeclaret/m2-reports-miniml/get/default.tar.bz2 |tar -xj
RUN mv guillaumeclaret-m2-reports-miniml-* m2-reports-miniml
WORKDIR m2-reports-miniml
RUN TERM=xterm make
WORKDIR ..

RUN curl -L https://bitbucket.org/guillaumeclaret/phd-reports-toplevel/get/default.tar.bz2 |tar -xj
RUN mv guillaumeclaret-phd-reports-toplevel-* phd-reports-toplevel
WORKDIR phd-reports-toplevel
RUN TERM=xterm make
WORKDIR ..

RUN curl -L https://bitbucket.org/guillaumeclaret/phd-reports-slidesejcp2013/get/default.tar.bz2 |tar -xj
RUN mv guillaumeclaret-phd-reports-slidesejcp2013-* phd-reports-slidesejcp2013
WORKDIR phd-reports-slidesejcp2013
RUN TERM=xterm make
WORKDIR ..

RUN curl -L https://bitbucket.org/guillaumeclaret/phd-reports-proposal2/get/default.tar.bz2 |tar -xj
RUN mv guillaumeclaret-phd-reports-proposal2-* phd-reports-proposal2
WORKDIR phd-reports-proposal2
RUN TERM=xterm make
WORKDIR ..

RUN curl -L https://bitbucket.org/guillaumeclaret/phd-reports-proposal/get/default.tar.bz2 |tar -xj
RUN mv guillaumeclaret-phd-reports-proposal-* phd-reports-proposal
WORKDIR phd-reports-proposal
RUN TERM=xterm make
WORKDIR ..

RUN curl -L https://bitbucket.org/guillaumeclaret/phd-reports-monad/get/default.tar.bz2 |tar -xj
RUN mv guillaumeclaret-phd-reports-monad-* phd-reports-monad
WORKDIR phd-reports-monad
RUN TERM=xterm make
WORKDIR ..

RUN curl -L https://bitbucket.org/guillaumeclaret/phd-reports-draft/get/default.tar.bz2 |tar -xj
RUN mv guillaumeclaret-phd-reports-draft-* phd-reports-draft
WORKDIR phd-reports-draft
RUN TERM=xterm make
WORKDIR ..

RUN curl -L https://bitbucket.org/guillaumeclaret/yale-reports-coqfu/get/default.tar.bz2 |tar -xj
RUN mv guillaumeclaret-yale-reports-coqfu-* yale-reports-coqfu
WORKDIR yale-reports-coqfu
RUN TERM=xterm make
WORKDIR ..

# RUN curl -L https://bitbucket.org/guillaumeclaret/yale-reports-queue/get/default.tar.bz2 |tar -xj
# RUN mv guillaumeclaret-yale-reports-queue-* yale-reports-queue
# WORKDIR yale-reports-queue
# RUN TERM=xterm make
# WORKDIR ..

# RUN curl -L https://bitbucket.org/guillaumeclaret/yale-reports-main/get/default.tar.bz2 |tar -xj
# RUN mv guillaumeclaret-yale-reports-main-* yale-reports-main
# WORKDIR yale-reports-main
# RUN TERM=xterm make
# WORKDIR ..

# Run Nginx.
USER root
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
