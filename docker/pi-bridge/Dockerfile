FROM node:25-bookworm-slim

RUN apt-get update \
  && apt-get install -y --no-install-recommends git ca-certificates ripgrep bash \
  && rm -rf /var/lib/apt/lists/*

RUN npm install -g @earendil-works/pi-coding-agent

WORKDIR /app
COPY docker/pi-bridge/server.mjs /app/server.mjs

EXPOSE 8787
CMD ["node", "/app/server.mjs"]
