.PHONY: deploy hot-reload renew-certs

deploy:
	sudo git pull
	docker compose build --no-cache && docker compose up -d

hot-reload:
	sudo git pull
	docker exec -it ReTargetOpenResty nginx -s reload

renew-certs:
	docker compose stop openresty
	docker compose run --rm certbot renew
	docker compose start openresty
	docker compose exec -it ReTargetOpenResty nginx -s reload
