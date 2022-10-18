FROM node:14.13.1

# Create app directory
WORKDIR /usr/src/apiServer

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
COPY package*.json ./

RUN npm install
# If you are building your code for production
# RUN npm ci --only=production

# Bundle app source
COPY . .

ENV DB_URL postgres://postgres:postgres@10.152.2.122:6543/webapps_mhbcn

EXPOSE 8080 8081

# CMD [ "bin/bash", "runall.sh" ]
# CMD ["node", "apiserver.js", "node", "depotapiserver.js"]