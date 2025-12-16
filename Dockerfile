# ===== BUILD =====
FROM node:20-bullseye-slim AS build
WORKDIR /app

# Narzędzia potrzebne dla zależności z native addonami i git dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 make g++ git \
  && rm -rf /var/lib/apt/lists/*

COPY package*.json ./
# Najczęściej ratuje konflikty peer deps na npm 7+
RUN npm install --no-audit --no-fund --legacy-peer-deps

COPY . .
RUN npm run build


# ===== RUN =====
FROM nginx:1.27-alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
