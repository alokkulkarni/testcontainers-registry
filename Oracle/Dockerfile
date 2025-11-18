# Oracle Database XE Dockerfile for TestContainers
# This provides a pre-configured Oracle Database Express Edition instance for integration testing

FROM container-registry.oracle.com/database/express:21.3.0-xe

# Set environment variables for Oracle XE
ENV ORACLE_PWD=oracle \
    ORACLE_CHARACTERSET=AL32UTF8

# Expose Oracle ports
# 1521 - Oracle database listener
# 5500 - Oracle Enterprise Manager Express
EXPOSE 1521 5500

# Health check - verify Oracle is running and accepting connections
HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=5 \
  CMD echo "SELECT 1 FROM DUAL;" | sqlplus -s sys/oracle@localhost:1521/XE as sysdba || exit 1

# Use the default entrypoint from the base image
