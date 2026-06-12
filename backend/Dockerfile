FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY src ./src

EXPOSE 3000

CMD ["sh", "-c", "sleep 20 && node src/db/migrate.js && node src/db/seed.js && node src/index.js"]
