.PHONY: deploy hot-reload

deploy:
	sudo git pull
	docker compose up -d --build

hot-reload:
	sudo git pull
	docker exec -it ReTargetOpenResty nginx -s reload
