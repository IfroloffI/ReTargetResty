.PHONY: deploy hot-reload

deploy:
	sudo git pull
	docker compose build --no-cache && docker compose up -d

hot-reload:
	sudo git pull
	docker exec -it ReTargetOpenResty nginx -s reload
