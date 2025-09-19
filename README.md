# Icecast KH Docker Image

A Docker container for running Icecast KH 2.4.0-kh22 streaming server based on Alpine Linux.

## Overview

This Docker image provides a lightweight, secure, and production-ready Icecast KH streaming server. It's built using Alpine Linux for minimal size and includes all necessary dependencies for audio streaming.

## Features

- **Icecast KH 2.4.0-kh22**: Latest version of Karl Heyes' Icecast fork
- **Alpine Linux 3.20**: Minimal base image for security and size
- **Multi-stage build**: Optimized build process for smaller final image
- **Non-root user**: Runs as `icecast` user for security
- **Health checks**: Built-in health monitoring
- **SSL/TLS support**: OpenSSL integration for secure streaming
- **Web interface**: Includes status-json.xsl and xml2json.xslt for API access

## Quick Start

### Build the Image

```bash
docker build -t icecast:2.4.0-kh22-alpine .
```

### Run the Container

```bash
docker run -d --rm --name icecast \
  -p 8000:8000 \
  -v /path/to/your/icecast.xml:/etc/icecast-kh/icecast.xml:ro \
  -v /path/to/logs:/var/log/icecast-kh \
  icecast:2.4.0-kh22-alpine
```

## Configuration

### Required Files

You need to provide an Icecast configuration file. The container expects it at `/etc/icecast-kh/icecast.xml`. You can mount your own configuration file:

```bash
-v /path/to/your/icecast.xml:/etc/icecast-kh/icecast.xml:ro
```

### Configuration Template

The container includes a template configuration file at `/etc/icecast-kh/icecast.xml`. You can customize it according to your needs.

### Logging

Logs are stored in `/var/log/icecast-kh` inside the container. Mount this directory to persist logs:

```bash
-v /path/to/host/logs:/var/log/icecast-kh
```

## Ports

- **8000**: Icecast web interface and streaming port (default)

You can map this to any host port:

```bash
-p 8080:8000  # Maps host port 8080 to container port 8000
```

## Volumes

| Container Path | Description | Mount Example |
|----------------|-------------|---------------|
| `/etc/icecast-kh/icecast.xml` | Icecast configuration file | `-v /host/config.xml:/etc/icecast-kh/icecast.xml:ro` |
| `/var/log/icecast-kh` | Log files directory | `-v /host/logs:/var/log/icecast-kh` |

## Health Check

The container includes a health check that monitors the Icecast server status every 30 seconds:

- **Interval**: 30 seconds
- **Timeout**: 5 seconds
- **Retries**: 5 attempts
- **Endpoint**: `http://127.0.0.1:8000/status-json.xsl`

## Security

- Runs as non-root user (`icecast`)
- Uses read-only configuration mount
- Minimal Alpine Linux base
- No unnecessary packages in final image

## Environment Variables

Currently, no environment variables are required. All configuration is done through the XML configuration file.

## Example Usage

### Basic Setup

```bash
# Create directories for configuration and logs
mkdir -p ./config ./logs

# Run Icecast with custom configuration
docker run -d --name icecast-server \
  -p 8000:8000 \
  -v $(pwd)/config/icecast.xml:/etc/icecast-kh/icecast.xml:ro \
  -v $(pwd)/logs:/var/log/icecast-kh \
  icecast:2.4.0-kh22-alpine
```

### Production Setup

```bash
# Run with restart policy and proper logging
docker run -d --name icecast-production \
  --restart unless-stopped \
  -p 8000:8000 \
  -v /etc/icecast/config.xml:/etc/icecast-kh/icecast.xml:ro \
  -v /var/log/icecast:/var/log/icecast-kh \
  icecast:2.4.0-kh22-alpine
```

## Monitoring

### Check Container Status

```bash
docker ps
docker logs icecast
```

### Health Check Status

```bash
docker inspect --format='{{.State.Health.Status}}' icecast
```

### Access Web Interface

Open your browser and navigate to:
- `http://localhost:8000` - Icecast admin interface
- `http://localhost:8000/status-json.xsl` - JSON status API

## Troubleshooting

### Common Issues

1. **Permission denied errors**: Ensure the mounted configuration file is readable
2. **Port already in use**: Change the host port mapping (`-p 8080:8000`)
3. **Configuration errors**: Check your `icecast.xml` syntax

### Debug Mode

Run the container interactively to debug issues:

```bash
docker run -it --rm \
  -p 8000:8000 \
  -v /path/to/config.xml:/etc/icecast-kh/icecast.xml:ro \
  icecast:2.4.0-kh22-alpine sh
```

## Building from Source

The Dockerfile uses a multi-stage build:

1. **Builder stage**: Compiles Icecast KH from source
2. **Runtime stage**: Creates minimal runtime image

### Build Requirements

- Docker with multi-stage build support
- Internet connection for downloading source code

### Custom Build

```bash
# Build with custom tag
docker build -t my-icecast:latest .

# Build with build arguments (if needed)
docker build --build-arg ALPINE_VERSION=3.20 -t icecast:custom .
```

## License

This Docker image is based on Icecast KH, which is licensed under GPL-2.0.

## Contributing

Issues and pull requests are welcome. Please ensure:

- Follow Docker best practices
- Test your changes thoroughly
- Update documentation as needed

## Support

For issues related to:
- **Docker image**: Open an issue in this repository
- **Icecast KH**: Visit the [official repository](https://github.com/karlheyes/icecast-kh)
- **Original Icecast**: Visit the [Xiph Foundation](https://icecast.org/)

## Changelog

- **2.4.0-kh22**: Initial release with Icecast KH 2.4.0-kh22
- Alpine Linux 3.20 base image
- Multi-stage build optimization
- Health check integration
- Security hardening with non-root user
