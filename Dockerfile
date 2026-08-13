FROM node:20-alpine

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm ci 


COPY . .

# COPY .env .env

EXPOSE 8080

CMD ["node", "server.js"]