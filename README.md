# TestContainers Registry

This directory contains custom Docker images for TestContainers used in integration testing.

## Structure

```
testcontainers-registry/
├── postgres/
│   └── Dockerfile
└── redis/
    ├── Dockerfile
    └── redis.conf
```

## Building Images

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

## Usage in Tests

### PostgreSQL
```java
@Container
static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("testcontainers-postgres:16-alpine")
    .withDatabaseName("beneficiaries")
    .withUsername("testuser")
    .withPassword("testpass");
```

### Redis
```java
@Container
static GenericContainer<?> redis = new GenericContainer<>("testcontainers-redis:7-alpine")
    .withExposedPorts(6379);
```

## Configuration

### PostgreSQL
- Database: `beneficiaries`
- User: `testuser`
- Password: `testpass`
- Port: `5432`

### Redis
- Port: `6379`
- Max Memory: `256mb`
- Eviction Policy: `allkeys-lru`
- Custom configuration in `redis.conf`

## Health Checks

Both containers include health checks:
- **PostgreSQL**: Checks `pg_isready` every 10 seconds
- **Redis**: Checks `redis-cli ping` every 10 seconds
