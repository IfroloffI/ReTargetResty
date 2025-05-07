.PHONY: deploy renew-certs stop clean git-pull-deploy

DOMAIN = re-target.ru
EMAIL = your@email.com

deploy:
	sudo mkdir -p {certs,letsencrypt,certbot/www,logs,lua-scripts}
	sudo openssl dhparam -out ./certs/dhparam.pem 2048
	sudo docker-compose up -d --build

renew-certs:
	sudo docker-compose run --rm certbot renew --force-renewal

stop:
	sudo docker-compose down

clean:
	sudo docker-compose down -v
	sudo rm -rf certs/* letsencrypt/* certbot/www/*

git-pull-deploy:
	sudo git pull && sudo make deploy