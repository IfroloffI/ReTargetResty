.PHONY: get-certs deploy hot-reload

get-certs:
	sudo git pull
	docker compose up -d --build certbot

deploy:
	sudo git pull
	docker compose up -d --build openresty

hot-reload:
	sudo git pull
	docker exec -it ReTargetOpenResty nginx -s reload
