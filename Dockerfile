# syntax=docker/dockerfile:1.4

FROM debian:bookworm-slim AS build

LABEL maintainer="price@orion-technologies.io"

ENV STEAM_USER="steam"
ENV STEAM_HOME="/home/${STEAM_USER}"
ENV STEAM_CMD_INSTALL_DIR="${STEAM_HOME}/Steam/steamcmd"
ARG steam_cmd_bin_reflection="${STEAM_HOME}/.local/bin"

RUN <<__EOR__
apt-get update
apt-get install -y --no-install-suggests --no-install-recommends \
    vim \
    curl \
    lib32stdc++6 \
    lib32gcc-s1 \
    ca-certificates=20230311 \
    dnsmasq \
    git \
    rsync

useradd -m "${STEAM_USER}"
su - "${STEAM_USER}" << __EOC__
(

    mkdir -p "${STEAM_CMD_INSTALL_DIR}"
    cd "${STEAM_CMD_INSTALL_DIR}"
    pwd
    curl -fsSL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -
)
mkdir -p "${steam_cmd_bin_reflection}"
cat << __EOF__ > "${steam_cmd_bin_reflection}/steamcmd"
#!/bin/bash
${STEAM_CMD_INSTALL_DIR}/steamcmd.sh \${@}
__EOF__
chmod 750 "${steam_cmd_bin_reflection}/steamcmd"
__EOC__

apt-get remove --purge --auto-remove -y
rm -rf /var/lib/apt/lists/*

__EOR__

FROM build as prod
WORKDIR "${STEAM_HOME}"
