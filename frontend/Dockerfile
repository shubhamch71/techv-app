# =========================
# Stage 1: Build React app
# =========================
FROM node:18-alpine3.18 AS builder

# Set working directory
WORKDIR /app

# Copy package.json and lockfile for dependency caching
COPY package*.json ./

# Install dependencies (ci = clean install, reproducible builds)
RUN npm ci --silent

# Copy rest of the source code
COPY . .

# Build the React app for production
RUN npm run build


# =========================
# Stage 2: Run with Nginx
# =========================
FROM nginx:alpine

# Set working directory
WORKDIR /usr/share/nginx/html

# Remove default static files
RUN rm -rf ./*

# Copy built React files from builder stage
COPY --from=builder /app/build ./

# Copy custom Nginx configuration
#COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# Expose HTTP port
EXPOSE 80

# Start Nginx in foreground
CMD ["nginx", "-g", "daemon off;"]

