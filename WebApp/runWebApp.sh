#!/bin/bash
docker run -it -p 8020:8020 \
     -e DJANGO_SUPERUSER_USERNAME=admin \
     -e DJANGO_SUPERUSER_PASSWORD=admin \
     -e DJANGO_SUPERUSER_EMAIL=admin@gov.in \
     --name webapps-mhbcn-nic-in \
     webapps-mhbcn-nic-in
     