FROM node:18-alpine AS builder
WORKDIR /app
ENV NODE_ENV=production
ENV NODE_OPTIONS=--openssl-legacy-provider

# Install dependencies
COPY package*.json ./
RUN npm ci --silent

# Copy source and build
COPY . .
RUN npm run build

### Serve with nginx
FROM nginx:stable-alpine
COPY --from=builder /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
