FROM node:18-alpine AS builder

RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    git

WORKDIR /app

COPY package*.json ./
COPY yarn.lock* ./

RUN npm ci --only=production && \
    npm cache clean --force

COPY . .

ARG SENTRY_AUTH_TOKEN
ARG SENTRY_ORG=your-org
ARG SENTRY_PROJECT=your-project
ARG VERSION=latest

ENV SENTRY_AUTH_TOKEN=${SENTRY_AUTH_TOKEN}
ENV NODE_ENV=production

RUN npm run build && \
    if [ -n "$SENTRY_AUTH_TOKEN" ]; then \
        npm install -g @sentry/cli && \
        sentry-cli releases new $VERSION && \
        sentry-cli releases files $VERSION upload-sourcemaps ./dist \
            --url-prefix "~/" \
            --rewrite && \
        sentry-cli releases finalize $VERSION; \
    fi

FROM node:18-alpine AS production

RUN apk add --no-cache \
    dumb-init \
    curl \
    ca-certificates \
    && rm -rf /var/cache/apk/*

RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

WORKDIR /app

COPY --from=builder --chown=nodejs:nodejs /app/dist ./dist
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nodejs:nodejs /app/package*.json ./

COPY --chown=nodejs:nodejs docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENV NODE_ENV=production \
    PORT=3000 \
    SENTRY_DSN="" \
    SENTRY_ENVIRONMENT=production \
    SENTRY_RELEASE=$VERSION

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:${PORT}/health || exit 1

USER nodejs

EXPOSE ${PORT}

ENTRYPOINT ["dumb-init", "--"]

CMD ["docker-entrypoint.sh"]

FROM builder AS development

RUN apk add --no-cache \
    bash \
    vim \
    jq

COPY package*.json ./
RUN npm ci && \
    npm cache clean --force

RUN npm install -g \
    nodemon \
    typescript \
    @sentry/cli \
    prettier \
    eslint

ENV NODE_ENV=development \
    DEBUG=* \
    SENTRY_ENVIRONMENT=development

VOLUME ["/app"]

CMD ["nodemon", "--inspect=0.0.0.0:9229", "src/index.ts"]

FROM builder AS test

COPY --from=builder /app /app

RUN npm ci --include=dev

RUN npm run lint

RUN npm run type-check

RUN npm run test:coverage

ARG SENTRY_AUTH_TOKEN
RUN if [ -n "$SENTRY_AUTH_TOKEN" ]; then \
        sentry-cli send-metric -n test.coverage \
            -v $(cat coverage/coverage-summary.json | jq '.total.lines.pct') \
            -u percent; \
    fi

FROM aquasec/trivy:latest AS scanner

COPY --from=production /app /app

RUN trivy filesystem --no-progress \
    --severity HIGH,CRITICAL \
    --exit-code 1 \
    /app

LABEL maintainer="Sentry <support@sentry.io>" \
      org.label-schema.name="Sentry Sentinel Theme Demo" \
      org.label-schema.description="Demo application showcasing Sentry integration" \
      org.label-schema.url="https://github.com/getsentry/sentinel-theme" \
      org.label-schema.vcs-url="https://github.com/getsentry/sentinel-theme.git" \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0"
