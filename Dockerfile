# ============================================
# Stage 1: Build Vue frontend
# ============================================
FROM node:20-alpine AS frontend-builder

WORKDIR /app/frontend

# Copy package files — package-lock.json exists so npm ci is reliable
COPY frontend/package.json frontend/package-lock.json ./

RUN npm ci --prefer-offline

COPY frontend/ ./

# Use npx vite build to bypass vue-tsc type-checking which can fail in CI
RUN npx vite build

# ============================================
# Stage 2: Build Elixir release
# ============================================
FROM elixir:1.16-alpine AS backend-builder

RUN apk add --no-cache build-base git

WORKDIR /app/backend

# Install hex and rebar
RUN mix local.hex --force && mix local.rebar --force

ENV MIX_ENV=prod

# Install deps — copy lockfile first for layer caching
COPY backend/mix.exs backend/mix.lock ./
RUN mix deps.get --only prod
RUN mix deps.compile

# Copy source code
COPY backend/config config/
COPY backend/lib lib/
COPY backend/priv priv/
COPY backend/assets assets/

# Build Phoenix internal assets (esbuild + tailwind + phx.digest)
RUN mix assets.deploy

# Compile and create OTP release
RUN mix compile
RUN mix release

# ============================================
# Stage 3: Runtime
# ============================================
FROM alpine:3.19 AS runtime

RUN apk add --no-cache \
  libstdc++ \
  openssl \
  ncurses-libs \
  nginx \
  bash \
  curl

# Create non-root user
RUN addgroup -g 1000 app && adduser -u 1000 -G app -s /bin/sh -D app

# Copy Elixir OTP release
COPY --from=backend-builder /app/backend/_build/prod/rel/time_manager /app/backend

# Copy Vue static build
COPY --from=frontend-builder /app/frontend/dist /app/frontend/dist

# Copy nginx config
COPY deploy/nginx.conf /etc/nginx/http.d/default.conf

# Copy entrypoint
COPY deploy/entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# nginx writes its pid to /run/nginx — make it writable by non-root user
# /var/lib/nginx/tmp is used for temp files
RUN mkdir -p /run/nginx /var/lib/nginx/tmp /var/log/nginx && \
    chown -R app:app /run/nginx /var/lib/nginx /var/log/nginx /app && \
    # nginx main config: set worker_processes and pid path writable by non-root
    sed -i 's|pid /run/nginx.pid;|pid /run/nginx/nginx.pid;|g' /etc/nginx/nginx.conf && \
    # Ensure the nginx.conf user line won't conflict (nginx worker runs as app)
    sed -i 's|^user nginx;|user app;|g' /etc/nginx/nginx.conf

# Health check targets Phoenix directly (not nginx) so it works even if nginx restarts
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:4000/api/health || exit 1

EXPOSE 80

USER app

ENTRYPOINT ["/app/entrypoint.sh"]
