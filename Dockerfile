# ====== BUILD STAGE ======
FROM node:20-alpine AS build

WORKDIR /app

# Instalacja zależności (lepsze cache)
COPY package*.json ./
# jeżeli używasz npm (masz package-lock.json) - to najlepsze:
COPY package-lock.json ./
RUN npm ci

# Kod aplikacji
COPY . .

# (Opcjonalnie) Vite env przez ARG -> ENV
# Jeśli w kodzie używasz VITE_* (np. import.meta.env.VITE_API_KEY),
# to zadziała w buildzie:
ARG VITE_API_KEY
ENV VITE_API_KEY=$VITE_API_KEY

# Build produkcyjny (Vite -> /app/dist)
RUN npm run build

# ====== RUNTIME STAGE ======
FROM nginx:1.27-alpine AS runtime

# Nginx config z repo (zakładam, że masz w root: nginx.conf) :contentReference[oaicite:1]{index=1}
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Statyczne pliki
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
