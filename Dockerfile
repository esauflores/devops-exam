FROM node:24.11.1-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY app/ .

CMD ["node", "index.js"]