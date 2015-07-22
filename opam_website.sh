#!/bin/sh

sudo -u clarus sh -c "\
  cd /home/clarus/www/opam-website/extraction &&\
  eval `opam config env` make &&\
  opam update &&\
  ./opamWebsite.native &&\
  cp -R html ../../coq-io/output/opam"
