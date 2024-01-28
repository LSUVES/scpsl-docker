# SCP: Secret Laboratory Dockerfile
Used to build lsuvgs/scpsl-exiled for dockerhub

Example docker-compose.yml
```yaml
version: '3'

services:
  server:
    image: lsuvgs/scpsl-exiled:latest
    container_name: scpsl
    restart: unless-stopped
    stdin_open: true
    tty: true
    ports:
      - 7777:7777
      - 7777:7777/udp
    environment:
      SCPSL_PORT: 7777
      EXILED_INSTALLER_ENABLED: true
      EXILED_INSTALLER_FORCED: false
    volumes:
      - ./scpsl-data/server:/config/SCP Secret Laboratory
      - ./scpsl-data/exiled:/config/EXILED
```
