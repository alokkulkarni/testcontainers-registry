# IBM DB2 TestContainer

This Docker image provides a pre-configured IBM DB2 Community Edition instance for integration testing with TestContainers.

## Features

- IBM DB2 Community Edition 11.5.9.0
- Pre-configured database instance: `testdb`
- Default user: `db2inst1`
- Ready for integration testing
- Health check included
- Fast startup configuration for testing

## Ports

| Port | Description |
|------|-------------|
| 50000 | DB2 database port |

## Default Configuration

- **Database Name**: testdb
- **Instance Name**: db2inst1
- **Username**: db2inst1
- **Password**: password
- **JDBC URL**: `jdbc:db2://localhost:50000/testdb`

## Building the Image

```bash
cd db2
docker build -t testcontainers/db2:latest .
```

## Running Locally

```bash
docker run -d \
  --name db2-test \
  -p 50000:50000 \
  --privileged \
  ghcr.io/alokkulkarni/testcontainers-registry/testcontainers/db2:latest
```

**Note**: DB2 requires `--privileged` mode to run properly.

Wait for DB2 to fully initialize (this can take 2-3 minutes). Check logs:

```bash
docker logs -f db2-test
```

## Using with TestContainers (Java)

### Add Dependency

```xml
<dependency>
    <groupId>org.testcontainers</groupId>
    <artifactId>db2</artifactId>
    <version>1.19.3</version>
    <scope>test</scope>
</dependency>
```

### Example Test

```java
import org.junit.jupiter.api.Test;
import org.testcontainers.containers.Db2Container;
import org.testcontainers.utility.DockerImageName;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

class Db2IntegrationTest {
    
    @Test
    void testDb2Connection() throws Exception {
        try (Db2Container db2 = new Db2Container(
                DockerImageName.parse("ghcr.io/alokkulkarni/testcontainers-registry/testcontainers/db2:latest")
                    .asCompatibleSubstituteFor("ibmcom/db2"))
                .acceptLicense()) {
            
            db2.start();
            
            String jdbcUrl = db2.getJdbcUrl();
            String username = db2.getUsername();
            String password = db2.getPassword();
            
            try (Connection conn = DriverManager.getConnection(jdbcUrl, username, password);
                 Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery("SELECT CURRENT TIMESTAMP FROM SYSIBM.SYSDUMMY1")) {
                
                if (rs.next()) {
                    System.out.println("DB2 timestamp: " + rs.getTimestamp(1));
                }
            }
        }
    }
}
```

### Spring Boot Configuration

```java
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.testcontainers.containers.Db2Container;
import org.testcontainers.utility.DockerImageName;

@TestConfiguration
public class Db2TestConfiguration {
    
    @Bean(initMethod = "start", destroyMethod = "stop")
    public Db2Container db2Container() {
        return new Db2Container(
            DockerImageName.parse("ghcr.io/alokkulkarni/testcontainers-registry/testcontainers/db2:latest")
                .asCompatibleSubstituteFor("ibmcom/db2"))
            .acceptLicense();
    }
    
    @DynamicPropertySource
    static void db2Properties(DynamicPropertyRegistry registry, Db2Container db2) {
        registry.add("spring.datasource.url", db2::getJdbcUrl);
        registry.add("spring.datasource.username", db2::getUsername);
        registry.add("spring.datasource.password", db2::getPassword);
        registry.add("spring.datasource.driver-class-name", () -> "com.ibm.db2.jcc.DB2Driver");
    }
}
```

### application-test.yml

```yaml
spring:
  datasource:
    # These will be overridden by @DynamicPropertySource
    url: jdbc:db2://localhost:50000/testdb
    username: db2inst1
    password: password
    driver-class-name: com.ibm.db2.jcc.DB2Driver
  jpa:
    database-platform: org.hibernate.dialect.DB2Dialect
    hibernate:
      ddl-auto: create-drop
```

## SQL Examples

### Create Table

```sql
CREATE TABLE users (
    id INTEGER NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);
```

### Insert Data

```sql
INSERT INTO users (username, email) VALUES ('testuser', 'test@example.com');
```

### Query Data

```sql
SELECT * FROM users;
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| DB2INSTANCE | DB2 instance name | db2inst1 |
| DB2INST1_PASSWORD | Instance password | password |
| DBNAME | Database name | testdb |
| LICENSE | Accept DB2 license | accept |
| BLU | Enable BLU Acceleration | false |
| ENABLE_ORACLE_COMPATIBILITY | Oracle compatibility mode | false |

## Troubleshooting

### Check DB2 Status

```bash
docker exec -it db2-test su - db2inst1 -c "db2 list active databases"
```

### View DB2 Logs

```bash
docker logs db2-test
```

### Connect to DB2 CLI

```bash
docker exec -it db2-test su - db2inst1
db2 connect to testdb
db2 "SELECT * FROM SYSIBM.SYSDUMMY1"
```

### Common Issues

1. **Container takes long to start**: DB2 initialization can take 2-3 minutes on first start. This is normal.

2. **Connection refused**: Ensure DB2 has fully started by checking the health status:
   ```bash
   docker inspect --format='{{json .State.Health}}' db2-test
   ```

3. **Privileged mode required**: DB2 requires `--privileged` flag to run properly in Docker.

## Performance Notes

- **Startup Time**: DB2 typically takes 2-3 minutes to fully initialize
- **Memory**: Minimum 2GB RAM recommended
- **CPU**: 2 cores recommended for testing
- This configuration is optimized for testing, not production use
- Sample database creation is disabled for faster startup

## License

IBM DB2 Community Edition is free for development and testing purposes. By using this image, you accept the IBM DB2 Community Edition license terms.

For production use, you need a valid IBM DB2 license.

## Links

- [IBM DB2 Community Edition](https://www.ibm.com/products/db2-database/developers)
- [DB2 Documentation](https://www.ibm.com/docs/en/db2/11.5)
- [TestContainers DB2 Module](https://www.testcontainers.org/modules/databases/db2/)
