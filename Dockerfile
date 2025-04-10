FROM node:23.11-alpine AS node_base
WORKDIR /app

FROM node_base AS builder

COPY package.json package-lock.json tsconfig.json ./
RUN --mount=type=cache,target=/root/.npm npm ci --ignore-scripts --omit-dev

COPY . ./
RUN --mount=type=cache,target=/root/.npm-production npm run build

FROM node_base AS release
COPY package.json package-lock.json ./
COPY --from=builder /app/build ./build
ENV NODE_ENV=production
RUN --mount=type=cache,target=/root/.npm npm ci --ignore-scripts --omit-dev
ENTRYPOINT ["node", "/app/build/index.js"]