FROM python:latest

ENV CSVERSION=2.1688-vsc1.39.2
ENV CODESERVER=https://github.com/cdr/code-server/releases/download/${CSVERSION}/code-server${CSVERSION}-linux-x86_64.tar.gz \
    VSCODE_EXTENSIONS="/root/.local/share/code-server/extensions" \
    LANG=en_US.UTF-8 \
    DISABLE_TELEMETRY=true

ADD $CODESERVER code-server.tar

RUN mkdir -p code-server \
    && tar -xf code-server.tar -C code-server --strip-components 1 \
    && cp code-server/code-server /usr/local/bin \
    && rm -rf code-server* && \
    apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends git locales htop curl wget less net-tools tmux net-tools && \
    locale-gen en_US.UTF-8 && \
    apt-get autoremove -y && \
    mkdir -p /home/coder/project && \
    code-server --install-extension ms-python.python && \
    code-server --install-extension humao.rest-client

WORKDIR /home/coder/project
VOLUME /home/coder/project
EXPOSE 8443
ENTRYPOINT ["code-server"]