.PHONY: deploy renew-certs stop clean git-pull-deploy

deploy:
	sudo mkdir -p {certs,letsencrypt,certbot/www,logs,lua-scripts}
	sudo test -f ./certs/dhparam.pem || sudo openssl dhparam -out ./certs/dhparam.pem 2048
	sudo docker-compose up -d --build

renew-certs:
	sudo docker-compose run --rm certbot renew --force-renewal
	sudo docker-compose exec openresty nginx -s reload

stop:
	sudo docker-compose down

clean:
	sudo docker-compose down -v
	sudo rm -rf certs/* letsencrypt/* certbot/www/*

git-pull-deploy:
	sudo git pull
	$(MAKE) deploy