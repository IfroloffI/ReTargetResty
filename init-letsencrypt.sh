#!/bin/bash
sudo make deploy
sudo docker-compose run --rm certbot renew