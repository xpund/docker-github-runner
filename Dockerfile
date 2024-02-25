FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy

# Install needed packages
RUN apt-get update \
    && apt-get install curl wget iptables python3 -y

# Install Docker
ENV DOCKER_CHANNEL=stable \
    DOCKER_VERSION=20.10.22 \
    DOCKER_COMPOSE_VERSION=2.14.2 \
    RUNNER_VERSION=2.313.0

USER root

RUN set -eux; \
    \
    arch="$(uname --m)"; \
    case "$arch" in \
    # amd64
        x86_64) dockerArch='x86_64' ;; \
    # arm64v8
        aarch64) dockerArch='aarch64' ;; \
        *) echo >&2 "error: unsupported architecture ($arch)"; exit 1 ;;\
    esac; \
    \
    if ! wget -O docker.tgz "https://download.docker.com/linux/static/${DOCKER_CHANNEL}/${dockerArch}/docker-${DOCKER_VERSION}.tgz"; then \
        echo >&2 "error: failed to download 'docker-${DOCKER_VERSION}' from '${DOCKER_CHANNEL}' for '${dockerArch}'"; \
        exit 1; \
    fi; \
    \
    tar --extract \
        --file docker.tgz \
        --strip-components 1 \
        --directory /usr/local/bin/ \
    ; \
    rm docker.tgz; \
    \
    if ! wget -O /usr/local/bin/docker-compose "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-linux-${dockerArch}"; then \
        echo >&2 "error: failed to download 'docker-compose-${DOCKER_COMPOSE_VERSION}' for '${dockerArch}'"; \
        exit 1; \
    fi; \
    \
    chmod +x /usr/local/bin/docker-compose; \
    ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose; \
    \
    dockerd --version; \
    docker --version

VOLUME /var/lib/docker

# Create a folder
RUN mkdir actions-runner
WORKDIR /actions-runner

# Download the latest runner package
RUN curl -o actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# Extract the installer
RUN tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# Install Dependencies
RUN ./bin/installdependencies.sh

# Clean Up
RUN	apt-get autoremove -y \
	&& apt-get clean -y \
	&& rm -rf /var/lib/apt/lists/*

# Create a folder for volumne
RUN mkdir /runner
VOLUME [ "/runner" ]

# Copy resources
COPY resources/etc /etc
ENV RUNNER_ALLOW_RUNASROOT=1