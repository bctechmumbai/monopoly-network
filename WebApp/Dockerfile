# Dockerfile

FROM python:3.7-buster

# install nginx
RUN apt-get update && apt-get install nginx vim -y --no-install-recommends

# copy source and install dependencies
# RUN mkdir -p /opt/app
WORKDIR /opt/app

COPY requirements.txt .
RUN pip install -r requirements.txt 

RUN mkdir -p pip_cache
RUN mkdir -p PIMS

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

COPY start-gunicorn-server.sh .

RUN chmod +x start-gunicorn-server.sh

COPY nginx.default /etc/nginx/sites-available/default


# COPY .pip_cache /opt/app/pip_cache/
COPY PIMS ./PIMS


#  --cache-dir /opt/app/pip_cache
RUN chown -R www-data:www-data .

ENV VYAPAR_API_URL "http://webapi.vyapar.mhbcn.gov.in:8081/api/"

# Start Gunicorn application server
CMD ["./start-gunicorn-server.sh"]

# start server nginx proxy server


EXPOSE 8080
STOPSIGNAL SIGTERM