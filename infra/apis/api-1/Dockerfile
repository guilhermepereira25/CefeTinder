FROM node:22-alpine3.21 AS builder

WORKDIR /app

COPY package.json package-lock.json tsconfig.json tsconfig.api1.json ./
RUN npm ci

COPY src ./src
RUN ./node_modules/.bin/tsc -p tsconfig.api1.json

# The generated gRPC JavaScript files are consumed at runtime by GraphQL clients.
RUN mkdir -p dist/src/grpc/proto && cp src/grpc/proto/*.js dist/src/grpc/proto/

FROM node:22-alpine3.21 AS runtime

WORKDIR /app
ENV NODE_ENV=production
ENV NODE_PATH=/app/dist
ENV PORT=4000

COPY package.json package-lock.json ./
RUN npm ci --omit=dev && npm cache clean --force

COPY --from=builder /app/dist ./dist

EXPOSE 4000

CMD ["node", "dist/src/graphql/server.js"]
