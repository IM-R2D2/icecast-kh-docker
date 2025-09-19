FROM alpine:3.20 AS builder

LABEL org.opencontainers.image.title="icecast-kh" org.opencontainers.image.description="Icecast KH 2.4.0-kh22 build on Alpine" \
      org.opencontainers.image.version="2.4.0-kh22" org.opencontainers.image.licenses="GPL-2.0" \
      org.opencontainers.image.authors="imR2D2 r2d2.director@gmail.com" \ 
      org.opencontainers.image.source="https://github.com/im-r2d2/icecast-kh-docker"



RUN apk add --no-cache \
    build-base libxslt-dev libvorbis-dev libogg-dev libxml2-dev openssl-dev \
    curl tar nano net-tools iputils-ping

WORKDIR /src

RUN curl -L -o icecast-kh.tar.gz \
      https://github.com/karlheyes/icecast-kh/archive/refs/tags/icecast-2.4.0-kh22.tar.gz \
 && tar xzf icecast-kh.tar.gz \
 && mv icecast-kh-icecast-2.4.0-kh22 icecast-kh
WORKDIR /src/icecast-kh

RUN sed -ri 's/(config_xml_parse_failure\s*\(\s*void\s*\*\s*ctx\s*,\s*)xmlError\s*\*/\1const xmlError */' src/cfgfile.c


RUN ./configure --with-openssl --prefix=/usr --sysconfdir=/etc/icecast-kh --localstatedir=/var \
 && make -j"$(nproc)" \
 && make install-strip

RUN curl -fsSL -o /usr/share/icecast/web/status-json.xsl \
      https://raw.githubusercontent.com/xiph/Icecast-Server/master/web/status-json.xsl \
 && curl -fsSL -o /usr/share/icecast/web/xml2json.xslt \
      https://raw.githubusercontent.com/xiph/Icecast-Server/master/web/xml2json.xslt

FROM alpine:3.20

RUN apk add --no-cache \
    libxslt libvorbis libogg libxml2 openssl mailcap ca-certificates

# Создание пользователя icecast с фиксированным UID/GID для совместимости с volume
RUN addgroup -S -g 10000 icecast \
 && adduser  -S -D -H -u 10000 -G icecast -s /sbin/nologin icecast \
 && mkdir -p /etc/icecast-kh /var/log/icecast-kh /run/icecast-kh \
 && chown -R icecast:icecast /var/log/icecast-kh /run/icecast-kh \
 && chmod 755 /var/log/icecast-kh

COPY --from=builder /usr/bin/icecast   /usr/bin/icecast
COPY --from=builder /usr/share/icecast /usr/share/icecast
COPY files/icecast.xml.template /etc/icecast-kh/icecast.xml

USER icecast:icecast
VOLUME ["/var/log/icecast-kh"]
EXPOSE 8000

ENTRYPOINT ["icecast"]
CMD ["-n","-c","/etc/icecast-kh/icecast.xml"]

HEALTHCHECK --interval=30s --timeout=5s --retries=5 \
  CMD curl -fsS http://127.0.0.1:8000/status-json.xsl >/dev/null || exit 1
