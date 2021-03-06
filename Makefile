build:
	date >force_update
	docker build --tag=web .

test:
	docker run -ti -p 80:80 web

start:
	docker run -ti -p 80:80 -v `pwd`/log:/var/log/nginx -d --name=web web

stop:
	docker kill web
	docker rm web
