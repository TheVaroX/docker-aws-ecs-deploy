# Imagen base Alpine con shell incluido
FROM alpine:latest

# Instala dependencias esenciales
RUN apk add --no-cache \
    docker \
    bash \
    curl \
    jq \
    python3 \
    py3-pip \
    git \
    busybox \
    && ln -sf /bin/busybox /bin/sh \
    && pip3 install --break-system-packages --no-cache-dir awscli

# Instala ecs-deploy (script oficial)
RUN curl -L https://raw.githubusercontent.com/silinternational/ecs-deploy/master/ecs-deploy \
    -o /usr/local/bin/ecs-deploy && \
    chmod +x /usr/local/bin/ecs-deploy

# Directorio de trabajo
WORKDIR /workspace

# Shell por defecto para GitLab CI
CMD ["/bin/sh"]