.PHONY: deploy hot-reload

deploy:
	sudo git pull
	docker compose build --no-cache && docker compose up -d
	docker network connect retarget_network ReTargetOpenResty
	docker restart ReTargetOpenResty

hot-reload:
	sudo git pull
	docker exec -it ReTargetOpenResty nginx -s reload

fix-network:
	docker network connect retarget_network ReTargetOpenResty
	docker restart ReTargetOpenResty