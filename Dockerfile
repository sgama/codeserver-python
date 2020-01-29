FROM python:latest

ENV VERSION=2.1698
ENV CSVERSION=2.1698-vsc1.41.1
ENV CODESERVER=https://github.com/cdr/code-server/releases/download/${VERSION}/code-server${CSVERSION}-linux-x86_64.tar.gz \
    DISABLE_TELEMETRY=true \
    SHELL=/bin/bash

ADD $CODESERVER code-server.tar

RUN mkdir -p code-server \
    && tar -xf code-server.tar -C code-server --strip-components 1 \
    && cp code-server/code-server /usr/local/bin \
    && rm -rf code-server* && \
    apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends bash git locales htop curl wget less more net-tools tmux net-tools && \
    apt-get autoremove -y && \
    mkdir -p /home/coder/project && \
    code-server --install-extension ms-python.python && \
    code-server --install-extension humao.rest-client && \
    code-server --install-extension HookyQR.beautify && \
    code-server --install-extension liximomo.sftp

WORKDIR /home/coder/project
VOLUME /home/coder/project
EXPOSE 8443
ENTRYPOINT ["code-server"]