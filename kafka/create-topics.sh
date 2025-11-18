#!/bin/bash
# Script to create pre-configured Kafka topics for testing

set -e

echo "Waiting for Kafka to be ready..."
sleep 10

# Create test topics
kafka-topics --bootstrap-server localhost:9092 --create --if-not-exists --topic test-topic --partitions 3 --replication-factor 1
kafka-topics --bootstrap-server localhost:9092 --create --if-not-exists --topic payment-events --partitions 3 --replication-factor 1
kafka-topics --bootstrap-server localhost:9092 --create --if-not-exists --topic notification-events --partitions 1 --replication-factor 1

echo "Topics created successfully"
kafka-topics --bootstrap-server localhost:9092 --list
