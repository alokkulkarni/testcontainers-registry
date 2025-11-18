# Apache Kafka TestContainer Configuration

This Docker image provides a pre-configured Apache Kafka instance using KRaft mode (no Zookeeper required) for integration testing with TestContainers.

## Features

- **KRaft Mode**: Uses Kafka's native metadata management (no Zookeeper dependency)
- **Auto-create Topics**: Enabled for convenience in testing
- **Pre-configured Topics**: Includes common test topics
- **Single Node**: Optimized for testing with minimal resources
- **Fast Startup**: Configured for quick initialization

## Ports

| Port | Service |
|------|---------|
| 9092 | Kafka Broker (PLAINTEXT) |
| 9093 | Controller Listener (Internal) |

## Default Configuration

- **Node ID**: 1
- **Process Roles**: broker, controller
- **Replication Factor**: 1 (single node)
- **Partitions**: 3 (for test-topic and payment-events)
- **Log Retention**: 24 hours
- **Log Segment Size**: 100 MB
- **Max Log Size**: 1 GB

## Pre-configured Topics

| Topic | Partitions | Replication Factor |
|-------|------------|-------------------|
| test-topic | 3 | 1 |
| payment-events | 3 | 1 |
| notification-events | 1 | 1 |

## Building the Image

```bash
docker build -t testcontainers-kafka:latest .
```

## Running Locally

```bash
docker run -d \
  --name kafka-test \
  -p 9092:9092 \
  -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://localhost:9092 \
  testcontainers-kafka:latest
```

## Using with TestContainers (Java)

### Basic Setup

```java
import org.testcontainers.kafka.KafkaContainer;
import org.testcontainers.utility.DockerImageName;

@Container
private static final KafkaContainer kafkaContainer = new KafkaContainer(
    DockerImageName.parse("testcontainers-kafka:latest")
);

@DynamicPropertySource
static void kafkaProperties(DynamicPropertyRegistry registry) {
    registry.add("spring.kafka.bootstrap-servers", kafkaContainer::getBootstrapServers);
}
```

### With Custom Configuration

```java
@Container
private static final KafkaContainer kafkaContainer = new KafkaContainer(
    DockerImageName.parse("testcontainers-kafka:latest")
)
.withEnv("KAFKA_AUTO_CREATE_TOPICS_ENABLE", "true")
.withEnv("KAFKA_LOG_RETENTION_HOURS", "1")
.withStartupTimeout(Duration.ofMinutes(2));
```

### Producer Example

```java
@Test
void testKafkaProducer() {
    Properties props = new Properties();
    props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, kafkaContainer.getBootstrapServers());
    props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
    props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
    
    KafkaProducer<String, String> producer = new KafkaProducer<>(props);
    
    ProducerRecord<String, String> record = new ProducerRecord<>("test-topic", "key", "value");
    producer.send(record).get();
    
    producer.close();
}
```

### Consumer Example

```java
@Test
void testKafkaConsumer() {
    Properties props = new Properties();
    props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, kafkaContainer.getBootstrapServers());
    props.put(ConsumerConfig.GROUP_ID_CONFIG, "test-group");
    props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");
    props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
    props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
    
    KafkaConsumer<String, String> consumer = new KafkaConsumer<>(props);
    consumer.subscribe(Collections.singletonList("test-topic"));
    
    ConsumerRecords<String, String> records = consumer.poll(Duration.ofSeconds(10));
    
    consumer.close();
}
```

## Spring Kafka Configuration

```yaml
spring:
  kafka:
    bootstrap-servers: ${KAFKA_BOOTSTRAP_SERVERS:localhost:9092}
    consumer:
      group-id: test-group
      auto-offset-reset: earliest
      key-deserializer: org.apache.kafka.common.serialization.StringDeserializer
      value-deserializer: org.apache.kafka.common.serialization.StringDeserializer
    producer:
      key-serializer: org.apache.kafka.common.serialization.StringSerializer
      value-serializer: org.apache.kafka.common.serialization.StringSerializer
```

## Creating Additional Topics

You can create topics dynamically in your tests:

```java
@BeforeAll
static void createTopics() throws Exception {
    String bootstrapServers = kafkaContainer.getBootstrapServers();
    
    Properties props = new Properties();
    props.put(AdminClientConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers);
    
    try (AdminClient admin = AdminClient.create(props)) {
        NewTopic newTopic = new NewTopic("my-topic", 3, (short) 1);
        admin.createTopics(Collections.singleton(newTopic)).all().get();
    }
}
```

## Environment Variables

You can customize the Kafka configuration using environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| KAFKA_NODE_ID | 1 | Unique node identifier |
| KAFKA_LISTENERS | PLAINTEXT://0.0.0.0:9092 | Listener addresses |
| KAFKA_ADVERTISED_LISTENERS | PLAINTEXT://localhost:9092 | Advertised listener addresses |
| KAFKA_AUTO_CREATE_TOPICS_ENABLE | true | Auto-create topics on first use |
| KAFKA_LOG_RETENTION_HOURS | 24 | Log retention time |
| KAFKA_LOG_RETENTION_BYTES | 1073741824 | Max log size (1 GB) |
| KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR | 1 | Offsets topic replication |

## Troubleshooting

### Container fails to start

Check the container logs:
```bash
docker logs kafka-test
```

### Cannot connect to Kafka

1. Verify the container is running:
```bash
docker ps | grep kafka
```

2. Check Kafka broker status:
```bash
docker exec kafka-test kafka-broker-api-versions --bootstrap-server localhost:9092
```

3. List topics:
```bash
docker exec kafka-test kafka-topics --bootstrap-server localhost:9092 --list
```

### Health check failing

The health check verifies that the Kafka broker API is responding:

```bash
docker exec kafka-test kafka-broker-api-versions --bootstrap-server localhost:9092
```

### Topic creation fails

Check if auto-create is enabled:
```bash
docker exec kafka-test kafka-configs --bootstrap-server localhost:9092 \
  --entity-type brokers --entity-default --describe | grep auto.create
```

## Performance Notes

This image is optimized for testing, not production:
- Single node (no replication)
- Small log segments
- Short retention periods
- Fast startup with minimal checks

For production deployments, use a proper Kafka cluster with:
- Multiple brokers for high availability
- Appropriate replication factors
- Longer retention periods
- Proper security configuration

## License

Apache Kafka is distributed under the Apache License 2.0.

This Docker image uses Confluent's Kafka distribution, which is also under the Apache License 2.0.
