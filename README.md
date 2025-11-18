# TestContainers Registry

This repository contains custom Docker images for TestContainers used in integration testing. Images are automatically built and published to GitHub Container Registry.

## Available Images

| Image | Base | Platforms | Tags |
|-------|------|-----------|------|
| PostgreSQL | postgres:16-alpine | amd64, arm64 | `latest`, `16`, `16-alpine` |
| Redis | redis:7-alpine | amd64, arm64 | `latest`, `7`, `7-alpine` |
| IBM MQ | ibm-messaging/mq:latest | amd64 | `latest`, `9.3` |

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

## Health Checks

All containers include health checks:
- **PostgreSQL**: Checks `pg_isready` every 10 seconds
- **Redis**: Checks `redis-cli ping` every 10 seconds
- **IBM MQ**: Checks `dspmq` (queue manager running) every 10 seconds

## CI/CD

Images are automatically built and pushed to GitHub Container Registry on:
- Push to `main` branch (when files in respective directories change)
- Manual workflow dispatch

### Workflow Triggers
- Changes to `postgres/**`
- Changes to `redis/**`
- Changes to `IBMMQ/**`
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

## Contributing

When adding new container images:
1. Create a new directory with the service name
2. Add a `Dockerfile` and any required configuration files
3. Add a `README.md` with usage instructions
4. Update the workflow in `.github/workflows/build-and-push.yaml`
5. Update this main README.md
