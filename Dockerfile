FROM python:latest

RUN apt-get update && \
    apt-get install -y \
        bash \
        ca-certificates \
        curl \
        dumb-init \
        git \
        htop \
        locales \
        lsb-release \
        man \
        nano \
        net-tools \
        openssh-client \
        pipenv \
        procps \
        sudo \
        tmux \
        vim \
        wget && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    # https://wiki.debian.org/Locale#Manually
    sed -i "s/# en_US.UTF-8/en_US.UTF-8/" /etc/locale.gen && \ 
    locale-gen && \
    # Create new user
    adduser --gecos '' --disabled-password coder --shell /bin/bash --home /home/coder && \
    echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd && \
    # Download and install fixuid
    ARCH="$(dpkg --print-architecture)" && \
    curl -fsSL "https://github.com/boxboat/fixuid/releases/download/v0.4.1/fixuid-0.4.1-linux-$ARCH.tar.gz" | tar -C /usr/local/bin -xzf - && \
    chown root:root /usr/local/bin/fixuid && \
    chmod 4755 /usr/local/bin/fixuid && \
    mkdir -p /etc/fixuid && \
    printf "user: coder\ngroup: coder\n" > /etc/fixuid/config.yml

# This way, if someone sets $DOCKER_USER, docker-exec will still work as
# the uid will remain the same. note: only relevant if -u isn't passed to docker-run.
USER 1000
ENV LANG=en_US.UTF-8
ENV SHELL=/bin/bash
WORKDIR /home/coder

RUN curl -fsSL https://code-server.dev/install.sh | sh && \
    code-server --install-extension ms-python.python && \
    code-server --install-extension humao.rest-client && \
    code-server --install-extension HookyQR.beautify && \
    code-server --install-extension liximomo.sftp && \
    code-server --install-extension eamodio.gitlens && \
    code-server --install-extension ms-azuretools.vscode-docker && \
    printf '{"workbench.colorTheme":"Default Dark+","rest-client.enableTelemetry":false,"editor.tokenColorCustomizations":null}\n' > ~/.local/share/code-server/User/settings.json

COPY entrypoint.sh /usr/bin/entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/usr/bin/entrypoint.sh", "--disable-telemetry", "--bind-addr", "0.0.0.0:8080", ".", "--auth", "none"]