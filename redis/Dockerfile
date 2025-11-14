# Redis Dockerfile for TestContainers Registry
FROM redis:7-alpine

# Copy custom Redis configuration
COPY redis.conf /usr/local/etc/redis/redis.conf

# Create data directory
RUN mkdir -p /data && \
    chown redis:redis /data

# Expose Redis port
EXPOSE 6379

# Health check
HEALTHCHECK --interval=10s --timeout=5s --start-period=5s --retries=3 \
  CMD redis-cli ping || exit 1

# Run Redis with custom configuration
CMD ["redis-server", "/usr/local/etc/redis/redis.conf"]
