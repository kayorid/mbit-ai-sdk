FROM node:20-alpine

WORKDIR /app

COPY package.json ./
RUN npm install --omit=dev

COPY app.js ./
COPY handlers/ ./handlers/
COPY adapters/ ./adapters/

ENV NODE_ENV=production
EXPOSE 3000

CMD ["node", "app.js"]
