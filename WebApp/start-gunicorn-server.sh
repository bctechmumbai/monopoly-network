#!/usr/bin/env bash
# start-server.sh
if [ -n "$DJANGO_SUPERUSER_USERNAME" ] && [ -n "$DJANGO_SUPERUSER_PASSWORD" ] ; then
    (cd PIMS; python manage.py createsuperuser --no-input)
fi
(cd PIMS; gunicorn PIMS.wsgi --user www-data --bind 0.0.0.0:8080 --workers 3) &
nginx -g "daemon off;"