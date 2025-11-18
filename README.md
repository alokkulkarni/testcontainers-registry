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
| Oracle XE | oracle/database:21.3.0-xe | amd64 | `latest`, `21`, `21.3`, `21.3.0` |

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
├── DB2/
│   ├── Dockerfile
│   └── README.md
├── Oracle/
│   ├── Dockerfile
│   └── README.md
└── .github/
    └── workflows/
        ├── build-postgres.yaml
        ├── build-redis.yaml
        ├── build-ibmmq.yaml
        ├── build-kafka.yaml
        ├── build-db2.yaml
        └── build-oracle.yaml
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

# Oracle XE
docker pull ghcr.io/alokkulkarni/testcontainers-registry/testcontainers/oracle-xe:latest
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
cd DB2
docker build -t testcontainers-db2:latest .
```

### Oracle XE
```bash
cd Oracle
docker build -t testcontainers-oracle-xe:latest .
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

### Oracle XE
```java
import org.testcontainers.containers.OracleContainer;
import org.testcontainers.utility.DockerImageName;

@Container
private static final OracleContainer oracleContainer = new OracleContainer(
    DockerImageName.parse("ghcr.io/alokkulkarni/testcontainers-registry/testcontainers/oracle-xe:latest")
        .asCompatibleSubstituteFor("gvenzl/oracle-xe")
).withReuse(true);

@DynamicPropertySource
static void oracleProperties(DynamicPropertyRegistry registry) {
    registry.add("spring.datasource.url", oracleContainer::getJdbcUrl);
    registry.add("spring.datasource.username", oracleContainer::getUsername);
    registry.add("spring.datasource.password", oracleContainer::getPassword);
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
- See [DB2/README.md](DB2/README.md) for detailed configuration

### Oracle XE
- Port: `1521` (Database), `5500` (EM Express)
- SID: `XE`
- Service Name: `XEPDB1` (Pluggable Database)
- Username: `system`
- Password: `oracle`
- JDBC URL: `jdbc:oracle:thin:@localhost:1521/XEPDB1`
- Requires: `--shm-size=1g` minimum
- See [Oracle/README.md](Oracle/README.md) for detailed configuration

## Health Checks

All containers include health checks:
- **PostgreSQL**: Checks `pg_isready` every 10 seconds
- **Redis**: Checks `redis-cli ping` every 10 seconds
- **IBM MQ**: Checks `dspmq` (queue manager running) every 10 seconds
- **Kafka**: Checks `kafka-broker-api-versions` every 10 seconds
- **DB2**: Checks `db2 connect to testdb` every 30 seconds
- **Oracle XE**: Checks `sqlplus` connection every 30 seconds

## CI/CD

Each image has its own dedicated GitHub Actions workflow that builds and pushes to GitHub Container Registry:

- **PostgreSQL**: `.github/workflows/build-postgres.yaml`
- **Redis**: `.github/workflows/build-redis.yaml`
- **IBM MQ**: `.github/workflows/build-ibmmq.yaml`
- **Kafka**: `.github/workflows/build-kafka.yaml`
- **DB2**: `.github/workflows/build-db2.yaml`
- **Oracle XE**: `.github/workflows/build-oracle.yaml`

Workflows are triggered on:
- Push to `main` branch (when files in respective directories change)
- Pull requests to `main` branch
- Manual workflow dispatch

### Workflow Triggers

Each workflow is triggered independently by changes to its specific directory:

- **PostgreSQL**: Changes to `postgres/**` or `.github/workflows/build-postgres.yaml`
- **Redis**: Changes to `redis/**` or `.github/workflows/build-redis.yaml`
- **IBM MQ**: Changes to `IBMMQ/**` or `.github/workflows/build-ibmmq.yaml`
- **Kafka**: Changes to `kafka/**` or `.github/workflows/build-kafka.yaml`
- **DB2**: Changes to `DB2/**` or `.github/workflows/build-db2.yaml`
- **Oracle XE**: Changes to `Oracle/**` or `.github/workflows/build-oracle.yaml`

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
- **Oracle XE**: Uses Oracle Database Express Edition
  - Free for development, testing, prototyping, and demonstrating applications
  - Production use requires appropriate Oracle Database licenses
  - Subject to Oracle Technology Network License Agreement

## Contributing

When adding new container images:
1. Create a new directory with the service name
2. Add a `Dockerfile` and any required configuration files
3. Add a `README.md` with usage instructions
4. Create a dedicated workflow in `.github/workflows/build-<service>.yaml`
5. Update this main README.md
