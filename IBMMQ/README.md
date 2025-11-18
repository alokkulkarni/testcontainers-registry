# IBM MQ TestContainer Configuration

This Docker image provides a pre-configured IBM MQ Developer Edition instance for integration testing with TestContainers.

## Features

- **Queue Manager**: QM1 (pre-configured)
- **Default Queues**: DEV.QUEUE.1, DEV.QUEUE.2, DEV.QUEUE.3, DEV.DEAD.LETTER.QUEUE
- **Channels**: DEV.APP.SVRCONN (application), DEV.ADMIN.SVRCONN (admin)
- **Authentication**: Pre-configured with test credentials
- **Metrics**: Prometheus metrics enabled on port 9157
- **Web Console**: Available on port 9443

## Ports

| Port | Service |
|------|---------|
| 1414 | MQ Listener (main connection port) |
| 9443 | MQ Web Console (HTTPS) |
| 9157 | Prometheus Metrics |

## Default Credentials

- **Admin User**: `admin`
- **Admin Password**: `passw0rd`
- **App User**: `app`
- **App Password**: `passw0rd`

## Building the Image

```bash
docker build -t testcontainers-ibmmq:latest .
```

## Running Locally

```bash
docker run -d \
  --name ibmmq-test \
  -p 1414:1414 \
  -p 9443:9443 \
  -e LICENSE=accept \
  -e MQ_QMGR_NAME=QM1 \
  -e MQ_APP_PASSWORD=passw0rd \
  testcontainers-ibmmq:latest
```

## Using with TestContainers (Java)

```java
@Container
private static final GenericContainer<?> ibmMqContainer = new GenericContainer<>("testcontainers-ibmmq:latest")
    .withExposedPorts(1414, 9443)
    .withEnv("LICENSE", "accept")
    .withEnv("MQ_QMGR_NAME", "QM1")
    .withEnv("MQ_APP_PASSWORD", "passw0rd")
    .waitingFor(Wait.forLogMessage(".*Started web server.*", 1))
    .withStartupTimeout(Duration.ofMinutes(2));

@DynamicPropertySource
static void ibmMqProperties(DynamicPropertyRegistry registry) {
    String host = ibmMqContainer.getHost();
    Integer port = ibmMqContainer.getMappedPort(1414);
    
    registry.add("ibm.mq.queue-manager", () -> "QM1");
    registry.add("ibm.mq.channel", () -> "DEV.APP.SVRCONN");
    registry.add("ibm.mq.conn-name", () -> host + "(" + port + ")");
    registry.add("ibm.mq.user", () -> "app");
    registry.add("ibm.mq.password", () -> "passw0rd");
}
```

## Connection String Format

```
hostname(port)/QM1
```

Example: `localhost(1414)/QM1`

## Web Console Access

Access the MQ Web Console at: `https://localhost:9443/ibmmq/console/`

- Username: `admin`
- Password: `passw0rd`

⚠️ **Note**: The web console uses a self-signed certificate, so you'll need to accept the security warning in your browser.

## Queue Configuration

The following queues are pre-configured:

- `DEV.QUEUE.1` - General purpose test queue
- `DEV.QUEUE.2` - General purpose test queue
- `DEV.QUEUE.3` - General purpose test queue
- `DEV.DEAD.LETTER.QUEUE` - Dead letter queue for undeliverable messages

All queues have:
- Maximum depth: 5000 messages
- Persistent messages: Enabled

## Security

This configuration is designed for **testing purposes only**. It includes:

- Simplified authentication
- Pre-configured users with known passwords
- Relaxed security settings

**Do not use this configuration in production environments.**

## Troubleshooting

### Container fails to start

Check the container logs:
```bash
docker logs ibmmq-test
```

### Cannot connect to MQ

1. Verify the container is running and healthy:
```bash
docker ps | grep ibmmq
```

2. Check MQ listener is active:
```bash
docker exec ibmmq-test dspmq
```

3. Verify channel status:
```bash
docker exec ibmmq-test runmqsc QM1 << EOF
DISPLAY CHSTATUS('DEV.APP.SVRCONN')
EOF
```

### Health check failing

The health check verifies that the queue manager is running. If it fails:

1. Check queue manager status:
```bash
docker exec ibmmq-test dspmq
```

2. View MQ error logs:
```bash
docker exec ibmmq-test cat /var/mqm/qmgrs/QM1/errors/AMQERR01.LOG
```

## License

This image uses IBM MQ Developer Edition, which is provided under the IBM International License Agreement for Non-Warranted Programs. By using this image, you accept the license terms.

For production use, you must obtain appropriate IBM MQ licenses.
