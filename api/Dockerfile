FROM node:16-slim

WORKDIR /app

ENV NODE_PATH ./dist
ENV NODE_ENV production

COPY package*.json ./

RUN npm install --production=false

COPY . ./

RUN npm run build

CMD [ "npm", "start" ]