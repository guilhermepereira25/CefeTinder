FROM node:22-alpine3.21 AS builder

WORKDIR /app

COPY package.json package-lock.json tsconfig.json tsconfig.api2.json ./
RUN npm ci

COPY src ./src
RUN ./node_modules/.bin/tsc -p tsconfig.api2.json

FROM node:22-alpine3.21 AS runtime

WORKDIR /app
ENV NODE_ENV=production
ENV WEBSOCKET_PORT=8080

COPY package.json package-lock.json ./
RUN npm ci --omit=dev && npm cache clean --force

COPY --from=builder /app/dist ./dist

EXPOSE 8080

CMD ["node", "dist/src/websocket/server.js"]
