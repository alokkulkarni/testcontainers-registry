# IBM MQ Developer Edition Dockerfile for TestContainers
# This provides a pre-configured IBM MQ instance for integration testing

FROM icr.io/ibm-messaging/mq:latest

# Set environment variables for MQ configuration
ENV LICENSE=accept \
    MQ_QMGR_NAME=QM1 \
    MQ_APP_PASSWORD=passw0rd \
    MQ_ADMIN_PASSWORD=passw0rd \
    MQ_ENABLE_METRICS=true

# Configure MQ with test-friendly defaults
# - Create default queue manager
# - Configure authentication
# - Set up default queues and channels

# Copy custom MQ configuration
COPY 20-config.mqsc /etc/mqm/

# Expose MQ ports
# 1414 - MQ Listener
# 9443 - MQ Web Console
# 9157 - Prometheus metrics
EXPOSE 1414 9443 9157

# Health check
HEALTHCHECK --interval=10s --timeout=5s --start-period=60s --retries=5 \
  CMD dspmq | grep RUNNING || exit 1

# Use the default entrypoint from the base image
# which starts the queue manager and web console
