.PHONY: get-certs deploy hot-reload

get-certs:
	sudo git pull
	docker compose up -d --build certbot

deploy:
	sudo git pull
	docker compose build --no-cache openresty && docker compose up -d openresty

hot-reload:
	sudo git pull
	docker exec -it ReTargetOpenResty nginx -s reload
