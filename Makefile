.PHONY: deploy hot-reload renew-certs

deploy:
	sudo git pull
	docker compose build --no-cache && docker compose up -d

hot-reload:
	sudo git pull
	docker exec -it ReTargetOpenResty nginx -s reload

renew-certs:
	docker compose run --rm \
	  -p 80:80 -p 443:443 \ 
	  certbot certonly --standalone \
	  -d re-target.ru \
  	  --non-interactive \
      --agree-tos \
  	  --email re-target-service@mail.ru \
      --preferred-challenges http \
      --force-renewal
	docker compose exec -it ReTargetOpenResty nginx -s reload
