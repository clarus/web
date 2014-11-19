# Web
The configuration of my web server.

    docker build --tag=web .
    docker run -ti -p 80:80 -v `pwd`/log:/var/log/nginx web
