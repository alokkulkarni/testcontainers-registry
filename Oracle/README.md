# Oracle Database XE TestContainer

This Docker image provides a pre-configured Oracle Database Express Edition (XE) instance for integration testing with TestContainers.

## Features

- Oracle Database Express Edition 21c (21.3.0)
- Pre-configured database instance: `XE`
- Default password: `oracle`
- Character set: AL32UTF8
- Ready for integration testing
- Health check included
- Enterprise Manager Express included

## Ports

| Port | Description |
|------|-------------|
| 1521 | Oracle database listener |
| 5500 | Oracle Enterprise Manager Express |

## Default Configuration

- **Database Name**: XE
- **SID**: XE
- **Service Name**: XEPDB1 (Pluggable Database)
- **System Password**: oracle
- **SYS/SYSTEM User**: oracle
- **JDBC URL**: `jdbc:oracle:thin:@localhost:1521/XE`
- **JDBC URL (PDB)**: `jdbc:oracle:thin:@localhost:1521/XEPDB1`

## Building the Image

```bash
cd Oracle
docker build -t testcontainers/oracle-xe:latest .
```

## Running Locally

```bash
docker run -d \
  --name oracle-xe-test \
  -p 1521:1521 \
  -p 5500:5500 \
  -e ORACLE_PWD=oracle \
  --shm-size=1g \
  ghcr.io/alokkulkarni/testcontainers-registry/testcontainers/oracle-xe:latest
```

**Note**: Oracle XE requires `--shm-size` to be set (minimum 1GB recommended).

Wait for Oracle to fully initialize (this can take 3-5 minutes). Check logs:

```bash
docker logs -f oracle-xe-test
```

Look for the message: `DATABASE IS READY TO USE!`

## Using with TestContainers (Java)

### Add Dependency

```xml
<dependency>
    <groupId>org.testcontainers</groupId>
    <artifactId>oracle-xe</artifactId>
    <version>1.19.3</version>
    <scope>test</scope>
</dependency>
```

### Example Test

```java
import org.junit.jupiter.api.Test;
import org.testcontainers.containers.OracleContainer;
import org.testcontainers.utility.DockerImageName;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

class OracleIntegrationTest {
    
    @Test
    void testOracleConnection() throws Exception {
        try (OracleContainer oracle = new OracleContainer(
                DockerImageName.parse("ghcr.io/alokkulkarni/testcontainers-registry/testcontainers/oracle-xe:latest")
                    .asCompatibleSubstituteFor("gvenzl/oracle-xe"))
                .withReuse(true)) {
            
            oracle.start();
            
            String jdbcUrl = oracle.getJdbcUrl();
            String username = oracle.getUsername();
            String password = oracle.getPassword();
            
            try (Connection conn = DriverManager.getConnection(jdbcUrl, username, password);
                 Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery("SELECT SYSDATE FROM DUAL")) {
                
                if (rs.next()) {
                    System.out.println("Oracle SYSDATE: " + rs.getTimestamp(1));
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
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.OracleContainer;
import org.testcontainers.utility.DockerImageName;

@TestConfiguration
public class OracleTestConfiguration {
    
    @Bean(initMethod = "start", destroyMethod = "stop")
    public OracleContainer oracleContainer() {
        return new OracleContainer(
            DockerImageName.parse("ghcr.io/alokkulkarni/testcontainers-registry/testcontainers/oracle-xe:latest")
                .asCompatibleSubstituteFor("gvenzl/oracle-xe"))
            .withReuse(true);
    }
    
    @DynamicPropertySource
    static void oracleProperties(DynamicPropertyRegistry registry, OracleContainer oracle) {
        registry.add("spring.datasource.url", oracle::getJdbcUrl);
        registry.add("spring.datasource.username", oracle::getUsername);
        registry.add("spring.datasource.password", oracle::getPassword);
        registry.add("spring.datasource.driver-class-name", () -> "oracle.jdbc.OracleDriver");
    }
}
```

### application-test.yml

```yaml
spring:
  datasource:
    # These will be overridden by @DynamicPropertySource
    url: jdbc:oracle:thin:@localhost:1521/XEPDB1
    username: system
    password: oracle
    driver-class-name: oracle.jdbc.OracleDriver
  jpa:
    database-platform: org.hibernate.dialect.Oracle12cDialect
    hibernate:
      ddl-auto: create-drop
```

## SQL Examples

### Connect to Database

```sql
-- Connect to CDB (Container Database)
sqlplus sys/oracle@localhost:1521/XE as sysdba

-- Connect to PDB (Pluggable Database)
sqlplus sys/oracle@localhost:1521/XEPDB1 as sysdba
```

### Create User

```sql
-- Switch to PDB
ALTER SESSION SET CONTAINER = XEPDB1;

-- Create user
CREATE USER testuser IDENTIFIED BY testpass;
GRANT CONNECT, RESOURCE TO testuser;
GRANT UNLIMITED TABLESPACE TO testuser;
```

### Create Table

```sql
CREATE TABLE users (
    id NUMBER GENERATED ALWAYS AS IDENTITY,
    username VARCHAR2(50) NOT NULL,
    email VARCHAR2(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);
```

### Insert Data

```sql
INSERT INTO users (username, email) VALUES ('testuser', 'test@example.com');
COMMIT;
```

### Query Data

```sql
SELECT * FROM users;
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| ORACLE_PWD | Password for SYS, SYSTEM users | oracle |
| ORACLE_CHARACTERSET | Database character set | AL32UTF8 |

## Troubleshooting

### Check Oracle Status

```bash
docker exec -it oracle-xe-test sqlplus sys/oracle@XE as sysdba
```

Then run:
```sql
SELECT STATUS FROM V$INSTANCE;
```

### View Oracle Logs

```bash
docker logs oracle-xe-test
```

### Check Listener Status

```bash
docker exec -it oracle-xe-test lsnrctl status
```

### Common Issues

1. **Container takes long to start**: Oracle XE initialization can take 3-5 minutes on first start. This is normal.

2. **Connection refused**: Ensure Oracle has fully started by checking the health status:
   ```bash
   docker inspect --format='{{json .State.Health}}' oracle-xe-test
   ```

3. **ORA-12505 error**: Make sure you're connecting to the correct service name (XE or XEPDB1).

4. **Shared memory error**: Oracle requires adequate shared memory. Use `--shm-size=1g` or higher.

5. **Insufficient space**: Oracle XE requires at least 2GB of free disk space.

## Performance Notes

- **Startup Time**: Oracle XE typically takes 3-5 minutes to fully initialize
- **Memory**: Minimum 2GB RAM recommended, 4GB+ for better performance
- **CPU**: 2 cores recommended for testing
- **Disk**: Requires at least 2GB free space
- This configuration is optimized for testing, not production use
- Consider using container reuse (`withReuse(true)`) to avoid repeated startups

## Oracle XE Limitations

Oracle Database Express Edition has the following limitations:
- Maximum of 2 CPUs
- Maximum of 2GB RAM
- Maximum of 12GB user data storage
- Single instance only

These limitations are suitable for development and testing purposes.

## License

Oracle Database Express Edition is free to use for development, testing, prototyping, and demonstrating applications.

For production use, you need appropriate Oracle Database licenses.

By using this image, you accept the [Oracle Technology Network License Agreement](https://www.oracle.com/downloads/licenses/oracle-free-license.html).

## Links

- [Oracle Database XE Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/21/xeinl/)
- [Oracle Container Registry](https://container-registry.oracle.com/)
- [TestContainers Oracle Module](https://www.testcontainers.org/modules/databases/oraclexe/)
- [Oracle JDBC Driver](https://www.oracle.com/database/technologies/appdev/jdbc-downloads.html)
