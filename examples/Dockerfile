# Sentry Sentinel Theme - Dockerfile Example
# Multi-stage build for a Node.js application with Sentry integration

# Build stage - compile TypeScript and bundle assets
FROM node:18-alpine AS builder

# Install build dependencies
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    git

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./
COPY yarn.lock* ./

# Install dependencies
RUN npm ci --only=production && \
    npm cache clean --force

# Copy source code
COPY . .

# Build application
ARG SENTRY_AUTH_TOKEN
ARG SENTRY_ORG=your-org
ARG SENTRY_PROJECT=your-project
ARG VERSION=latest

ENV SENTRY_AUTH_TOKEN=${SENTRY_AUTH_TOKEN}
ENV NODE_ENV=production

# Build and upload source maps to Sentry
RUN npm run build && \
    if [ -n "$SENTRY_AUTH_TOKEN" ]; then \
        npm install -g @sentry/cli && \
        sentry-cli releases new $VERSION && \
        sentry-cli releases files $VERSION upload-sourcemaps ./dist \
            --url-prefix "~/" \
            --rewrite && \
        sentry-cli releases finalize $VERSION; \
    fi

# Production stage - minimal runtime image
FROM node:18-alpine AS production

# Install runtime dependencies
RUN apk add --no-cache \
    dumb-init \
    curl \
    ca-certificates \
    && rm -rf /var/cache/apk/*

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Set working directory
WORKDIR /app

# Copy built application from builder stage
COPY --from=builder --chown=nodejs:nodejs /app/dist ./dist
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nodejs:nodejs /app/package*.json ./

# Copy startup scripts
COPY --chown=nodejs:nodejs docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Environment variables
ENV NODE_ENV=production \
    PORT=3000 \
    SENTRY_DSN="" \
    SENTRY_ENVIRONMENT=production \
    SENTRY_RELEASE=$VERSION

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:${PORT}/health || exit 1

# Switch to non-root user
USER nodejs

# Expose port
EXPOSE ${PORT}

# Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]

# Start application
CMD ["docker-entrypoint.sh"]

# Development stage - includes dev dependencies and tools
FROM builder AS development

# Install development tools
RUN apk add --no-cache \
    bash \
    vim \
    jq

# Install dev dependencies
COPY package*.json ./
RUN npm ci && \
    npm cache clean --force

# Install global tools
RUN npm install -g \
    nodemon \
    typescript \
    @sentry/cli \
    prettier \
    eslint

# Environment for development
ENV NODE_ENV=development \
    DEBUG=* \
    SENTRY_ENVIRONMENT=development

# Volume for code mounting
VOLUME ["/app"]

# Development command
CMD ["nodemon", "--inspect=0.0.0.0:9229", "src/index.ts"]

# Test stage - for running tests
FROM builder AS test

# Copy test files
COPY --from=builder /app /app

# Install test dependencies
RUN npm ci --include=dev

# Run linting
RUN npm run lint

# Run type checking
RUN npm run type-check

# Run tests with coverage
RUN npm run test:coverage

# Upload test results to Sentry
ARG SENTRY_AUTH_TOKEN
RUN if [ -n "$SENTRY_AUTH_TOKEN" ]; then \
        sentry-cli send-metric -n test.coverage \
            -v $(cat coverage/coverage-summary.json | jq '.total.lines.pct') \
            -u percent; \
    fi

# Scanner stage - security scanning
FROM aquasec/trivy:latest AS scanner

# Copy the built image for scanning
COPY --from=production /app /app

# Run security scan
RUN trivy filesystem --no-progress \
    --severity HIGH,CRITICAL \
    --exit-code 1 \
    /app

# Metadata
LABEL maintainer="Sentry <support@sentry.io>" \
      org.label-schema.name="Sentry Sentinel Theme Demo" \
      org.label-schema.description="Demo application showcasing Sentry integration" \
      org.label-schema.url="https://github.com/getsentry/sentinel-theme" \
      org.label-schema.vcs-url="https://github.com/getsentry/sentinel-theme.git" \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0"
