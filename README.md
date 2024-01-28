# SCP: Secret Laboratory Dockerfile
Used to build lsuvgs/scpsl-exiled for dockerhub


## Summary
The lsuvgs/scpsl-exiled image was an attempt by me (Tech Officer 2023-2024) to fix issues present with our previous build, based on [t3l3tubie/scpsl](https://hub.docker.com/r/t3l3tubie/scpsl).

Unlike [t3l3tubie/scpsl](https://hub.docker.com/r/t3l3tubie/scpsl), this image is built in two stages from a general purpose ubuntu 20.04 base image, this provides the correct version of GLibC (which I did not feel qualified enough to try and upgrade manually due to compatibility issues) and allows for a couple of useful optimisations and improvements from the original.


## Configuration

### ENV Variables

| Variable | Description | Default Value |
|---|---|---|
| SCPSL_PORT | Sets the port variable for LocalAdmin on container start | 7777 |
| EXILED_INSTALLER_ENABLED | Determines whether the container should attempt to install EXILED if missing<br>**_This will not disable an already present EXILED installation_** | true |
| EXILED_INSTALLER_FORCED  | If enabled, forces the container to attempt an EXILED installation, regardless of file presence.<br>Typically useful for repairing an installation or updating to a newer version | false |


### Volumes & Mountpoints
`/config` is provided as a read/write moutpoint for `/home/usr/.config/`
- `/config/SCP: Secret Laboratory` contains SCP:SL configs
- `/config/EXILED` contains EXILED configs

**_All volumes should be read/writable by GUID 22035 to ensure functionality_**


## Example docker-compose.yml
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
