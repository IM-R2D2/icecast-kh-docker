# Icecast KH Docker Image

Docker image for Icecast 2.4.0-kh22 (KH branch).

## Usage
```bash
docker run -d --name icecast \
  -p 8000:8000 \
  -v $(pwd)/icecast.xml:/etc/icecast-kh/icecast.xml:ro \
  -v $(pwd)/logs:/var/log/icecast-kh \
  ghcr.io/imr2d2/icecast:2.4.0-kh22
