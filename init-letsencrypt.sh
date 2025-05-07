#!/bin/bash
sudo docker-compose stop openresty
sudo docker-compose up certbot
sudo docker-compose up -d