.PHONY: get-certs deploy hot-reload renew-certs

get-certs:
	sudo git pull
	docker compose up -d --build certbot
	sleep 15
	docker stop certbot
	docker rm -f certbot

deploy:
	sudo git pull
	docker compose up -d --build openresty

hot-reload:
	sudo git pull
	docker cp ./nginx.conf ReTargetOpenResty:/usr/local/openresty/nginx/conf/
	docker exec -it ReTargetOpenResty nginx -s reload

renew-certs:
	docker compose stop openresty
	docker rm -f openresty
	docker compose up -d certbot
	sleep 15
	docker compose stop certbot
	docker compose rm -f certbot
	docker compose up -d openresty