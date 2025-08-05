# === Stage 1: Install Cesium via npm ===
FROM node:20-alpine AS builder

WORKDIR /cesium
RUN npm init -y
RUN npm install cesium

# === Stage 2: NGINX static server ===
FROM nginx:alpine

# Install openssl for cert generation
RUN apk add --no-cache openssl && \
    mkdir -p /etc/nginx/certs /usr/share/nginx/html /usr/share/nginx/cesium

RUN apk add --no-cache shadow && \
    usermod -u 1337 nginx

# Generate self-signed cert
COPY generate-cert.sh /generate-cert.sh
RUN chmod +x /generate-cert.sh && /generate-cert.sh

# Copy nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy Cesium build into /usr/share/nginx/html/Cesium/
COPY --from=builder /cesium/node_modules/cesium/Build/Cesium /usr/share/nginx/cesium/Cesium

# Fix permissions
RUN chmod -R 755 /usr/share/nginx/html

EXPOSE 443
CMD ["nginx", "-g", "daemon off;"]
