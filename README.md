# TestContainers Registry

This repository contains custom Docker images for TestContainers used in integration testing. Images are automatically built and published to GitHub Container Registry.

## Available Images

| Image | Base | Platforms | Tags |
|-------|------|-----------|------|
| PostgreSQL | postgres:16-alpine | amd64, arm64 | `latest`, `16`, `16-alpine` |
| Redis | redis:7-alpine | amd64, arm64 | `latest`, `7`, `7-alpine` |
| IBM MQ | ibm-messaging/mq:latest | amd64 | `latest`, `9.3` |
| Kafka | confluentinc/cp-kafka:7.6.0 | amd64, arm64 | `latest`, `7.6`, `7.6.0` |
| DB2 | db2_community/db2:11.5.9.0 | amd64 | `latest`, `11.5`, `11.5.9` |

## Structure

```
testcontainers-registry/
├── postgres/
│   └── Dockerfile
├── redis/
│   ├── Dockerfile
│   └── redis.conf
├── IBMMQ/
│   ├── Dockerfile
│   ├── 20-config.mqsc
│   └── README.md
├── kafka/
│   ├── Dockerfile
│   ├── create-topics.sh
│   └── README.md
├── db2/
│   ├── Dockerfile
│   └── README.md
└── .github/
    └── workflows/
        └── build-and-push.yaml
```

## Using Pre-built Images

Pull images from GitHub Container Registry:

```bash
# PostgreSQL
docker pull ghcr.io/alokkulkarni/testcontainers-registry/testcontainers/postgres:latest

# Redis
docker pull ghcr.io/alokkulkarni/testcontainers-registry/testcontainers/redis:latest

# IBM MQ
docker pull ghcr.io/alokkulkarni/testcontainers-registry/testcontainers/ibmmq:latest

# Kafka
docker pull ghcr.io/alokkulkarni/testcontainers-registry/testcontainers/kafka:latest

# DB2
docker pull ghcr.io/alokkulkarni/testcontainers-registry/testcontainers/db2:latest
```

## Building Images Locally

### PostgreSQL
```bash
cd postgres
docker build -t testcontainers-postgres:16-alpine .
```

### Redis
```bash
cd redis
docker build -t testcontainers-redis:7-alpine .
```

### IBM MQ
```bash
cd IBMMQ
docker build -t testcontainers-ibmmq:latest .
```

### Kafka
```bash
cd kafka
docker build -t testcontainers-kafka:latest .
```

### DB2
```bash
cd db2
docker build -t testcontainers-db2:latest .
```

## Usage in Tests

### PostgreSQL
```java
@Container
static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("ghcr.io/alokkulkarni/testcontainers-registry/testcontainers/postgres:latest")
    .withDatabaseName("beneficiaries")
    .withUsername("testuser")
    .withPassword("testpass");
```

### Redis
```java
@Container
static GenericContainer<?> redis = new GenericContainer<>("ghcr.io/alokkulkarni/testcontainers-registry/testcontainers/redis:latest")
    .withExposedPorts(6379);
```

### IBM MQ
```java
@Container
private static final GenericContainer<?> ibmMqContainer = new GenericContainer<>("ghcr.io/alokkulkarni/testcontainers-registry/testcontainers/ibmmq:latest")
    .withExposedPorts(1414, 9443)
    .withEnv("LICENSE", "accept")
    .withEnv("MQ_QMGR_NAME", "QM1")
    .withEnv("MQ_APP_PASSWORD", "passw0rd")
    .waitingFor(Wait.forLogMessage(".*Started web server.*", 1))
    .withStartupTimeout(Duration.ofMinutes(2));
```

### Kafka
```java
import org.testcontainers.kafka.KafkaContainer;
import org.testcontainers.utility.DockerImageName;

@Container
private static final KafkaContainer kafkaContainer = new KafkaContainer(
    DockerImageName.parse("ghcr.io/alokkulkarni/testcontainers-registry/testcontainers/kafka:latest")
);

@DynamicPropertySource
static void kafkaProperties(DynamicPropertyRegistry registry) {
    registry.add("spring.kafka.bootstrap-servers", kafkaContainer::getBootstrapServers);
}
```

### DB2
```java
import org.testcontainers.containers.Db2Container;
import org.testcontainers.utility.DockerImageName;

@Container
private static final Db2Container db2Container = new Db2Container(
    DockerImageName.parse("ghcr.io/alokkulkarni/testcontainers-registry/testcontainers/db2:latest")
        .asCompatibleSubstituteFor("ibmcom/db2")
).acceptLicense();

@DynamicPropertySource
static void db2Properties(DynamicPropertyRegistry registry) {
    registry.add("spring.datasource.url", db2Container::getJdbcUrl);
    registry.add("spring.datasource.username", db2Container::getUsername);
    registry.add("spring.datasource.password", db2Container::getPassword);
}
```

## Configuration

### PostgreSQL
- Database: `beneficiaries`
- User: `testuser`
- Password: `testpass`
- Port: `5432`
- Includes: Initial schema and test data

### Redis
- Port: `6379`
- Max Memory: `256mb`
- Eviction Policy: `allkeys-lru`
- Custom configuration in `redis.conf`

### IBM MQ
- Queue Manager: `QM1`
- Port: `1414` (MQ Listener)
- Web Console: `9443` (HTTPS)
- Metrics: `9157` (Prometheus)
- Default Queues: `DEV.QUEUE.1`, `DEV.QUEUE.2`, `DEV.QUEUE.3`
- Credentials: `admin/passw0rd`, `app/passw0rd`
- See [IBMMQ/README.md](IBMMQ/README.md) for detailed configuration

### Kafka
- Port: `9092` (Kafka Broker)
- Mode: KRaft (no Zookeeper required)
- Auto-create Topics: Enabled
- Pre-configured Topics: `test-topic`, `payment-events`, `notification-events`
- Replication Factor: 1 (single node)
- See [kafka/README.md](kafka/README.md) for detailed configuration

### DB2
- Port: `50000` (Database)
- Instance: `db2inst1`
- Database: `testdb`
- Username: `db2inst1`
- Password: `password`
- JDBC URL: `jdbc:db2://localhost:50000/testdb`
- Requires: `--privileged` mode
- See [db2/README.md](db2/README.md) for detailed configuration

## Health Checks

All containers include health checks:
- **PostgreSQL**: Checks `pg_isready` every 10 seconds
- **Redis**: Checks `redis-cli ping` every 10 seconds
- **IBM MQ**: Checks `dspmq` (queue manager running) every 10 seconds
- **Kafka**: Checks `kafka-broker-api-versions` every 10 seconds
- **DB2**: Checks `db2 connect to testdb` every 30 seconds

## CI/CD

Images are automatically built and pushed to GitHub Container Registry on:
- Push to `main` branch (when files in respective directories change)
- Manual workflow dispatch

### Workflow Triggers
- Changes to `postgres/**`
- Changes to `redis/**`
- Changes to `IBMMQ/**`
- Changes to `kafka/**`
- Changes to `db2/**`
- Changes to `.github/workflows/build-and-push.yaml`

### Image Tags
Images are tagged with:
- `latest` - Latest stable version
- Version number (e.g., `16`, `7`, `9.3`)
- Version with variant (e.g., `16-alpine`, `7-alpine`)
- SHA-based tags for specific commits

## License Notes

- **PostgreSQL & Redis**: Open source (MIT/BSD licenses)
- **IBM MQ**: Uses IBM MQ Developer Edition under IBM International License Agreement for Non-Warranted Programs
  - Free for development and testing
  - Production use requires appropriate IBM MQ licenses
- **Kafka**: Apache License 2.0 (using Confluent's distribution)
- **DB2**: Uses IBM DB2 Community Edition
  - Free for development and testing
  - Production use requires appropriate IBM DB2 licenses

## Contributing

When adding new container images:
1. Create a new directory with the service name
2. Add a `Dockerfile` and any required configuration files
3. Add a `README.md` with usage instructions
4. Update the workflow in `.github/workflows/build-and-push.yaml`
5. Update this main README.md
