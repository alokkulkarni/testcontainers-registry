# PostgreSQL Dockerfile for TestContainers Registry
FROM postgres:16

# Set environment variables
# ENV POSTGRES_DB=beneficiaries
# ENV POSTGRES_USER=testuser
# ENV POSTGRES_PASSWORD=testpass

# Copy initialization scripts if needed
# COPY init.sql /docker-entrypoint-initdb.d/

# Expose PostgreSQL port
EXPOSE 5432

# Health check
HEALTHCHECK --interval=10s --timeout=5s --start-period=10s --retries=5 \
  CMD pg_isready -U testuser -d beneficiaries || exit 1

# Use default postgres entrypoint
CMD ["postgres"]
