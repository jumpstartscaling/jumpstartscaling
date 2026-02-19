# God-Mode Router + Sites - Production Build
# Builds both jumpstartscaling and chrisamaya, then serves via router.js
# Coolify: Build from this Dockerfile, SITES_BASE_PATH=/app

FROM node:20-alpine AS builder-js
WORKDIR /app

# Build jumpstartscaling
COPY sites/jumpstartscaling/package*.json sites/jumpstartscaling/
WORKDIR /app/sites/jumpstartscaling
RUN npm ci --legacy-peer-deps
COPY sites/jumpstartscaling/ .
RUN npm run build

# Build chrisamaya
WORKDIR /app
COPY sites/chrisamaya/package*.json sites/chrisamaya/
WORKDIR /app/sites/chrisamaya
RUN npm ci --legacy-peer-deps
COPY sites/chrisamaya/ .
RUN npm run build

# Copy root deps for router
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev

# Final image
FROM node:20-alpine
WORKDIR /app

ENV NODE_ENV=production
ENV PORT=8100
ENV SITES_BASE_PATH=/app

# Copy router and built sites
COPY --from=builder-js /app/node_modules ./node_modules
COPY --from=builder-js /app/package.json ./
COPY router.js ./
COPY --from=builder-js /app/sites/jumpstartscaling/dist ./sites/jumpstartscaling/dist
COPY --from=builder-js /app/sites/chrisamaya/dist ./sites/chrisamaya/dist

# Coolify/Traefik health check
RUN apk add --no-cache wget
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -q -O- http://localhost:8100/ || exit 1

EXPOSE 8100
CMD ["node", "router.js"]
