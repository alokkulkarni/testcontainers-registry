# Apache Kafka Dockerfile for TestContainers
# This provides a pre-configured Kafka instance with KRaft (no Zookeeper required)

FROM confluentinc/cp-kafka:7.6.0

# Set environment variables for KRaft mode
ENV KAFKA_NODE_ID=1 \
    KAFKA_PROCESS_ROLES=broker,controller \
    KAFKA_CONTROLLER_QUORUM_VOTERS=1@localhost:9093 \
    KAFKA_LISTENERS=PLAINTEXT://0.0.0.0:9092,CONTROLLER://0.0.0.0:9093 \
    KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://localhost:9092 \
    KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT \
    KAFKA_CONTROLLER_LISTENER_NAMES=CONTROLLER \
    KAFKA_INTER_BROKER_LISTENER_NAME=PLAINTEXT \
    KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1 \
    KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR=1 \
    KAFKA_TRANSACTION_STATE_LOG_MIN_ISR=1 \
    KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS=0 \
    KAFKA_AUTO_CREATE_TOPICS_ENABLE=true \
    KAFKA_LOG_RETENTION_HOURS=24 \
    KAFKA_LOG_RETENTION_BYTES=1073741824 \
    KAFKA_LOG_SEGMENT_BYTES=104857600 \
    CLUSTER_ID=MkU3OEVBNTcwNTJENDM2Qk

# Create topics directory for pre-configured topics
RUN mkdir -p /etc/kafka/topics

# Copy topic creation script
COPY create-topics.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/create-topics.sh

# Expose Kafka ports
# 9092 - Kafka broker (PLAINTEXT)
# 9093 - Controller listener
EXPOSE 9092 9093

# Health check
HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=5 \
  CMD kafka-broker-api-versions --bootstrap-server localhost:9092 || exit 1

# Use the default entrypoint from the base image
