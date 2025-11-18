# IBM DB2 Dockerfile for TestContainers
# This provides a pre-configured DB2 instance for integration testing

FROM icr.io/db2_community/db2:11.5.9.0

# Set environment variables for DB2
ENV LICENSE=accept \
    DB2INSTANCE=db2inst1 \
    DB2INST1_PASSWORD=password \
    DBNAME=testdb \
    BLU=false \
    ENABLE_ORACLE_COMPATIBILITY=false \
    UPDATEAVAIL=NO \
    TO_CREATE_SAMPLEDB=false \
    PERSISTENT_HOME=false \
    HADR_ENABLED=false \
    ETCD_ENABLED=false

# Expose DB2 port
# 50000 - DB2 database port
EXPOSE 50000

# Health check - verify DB2 is running and database is active
HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=5 \
  CMD su - db2inst1 -c "db2 connect to testdb" || exit 1

# Use the default entrypoint from the base image
