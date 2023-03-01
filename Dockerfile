# syntax=docker/dockerfile:1.4

FROM debian:bullseye-slim AS build

LABEL maintainer="price@orion-technologies.io"

ENV USER="steam"
ENV USER_HOME="/home/${USER}"
ENV STEAM_CMD_INSTALL_DIR="${USER_HOME}/Steam/steamcmd"
ARG steam_cmd_bin_reflection="${USER_HOME}/.local/bin"

RUN <<__EOR__
apt-get update
apt-get install -y --no-install-suggests --no-install-recommends \
    vim=2:8.2.2434-3+deb11u1 \
    curl \
    lib32stdc++6=10.2.1-6 \
    lib32gcc-s1=10.2.1-6 \
    ca-certificates=20210119 \
    dnsmasq=2.85-1 \
    git=1:2.30.2-1 \
    rsync=3.2.3-4+deb11u1

useradd -m "${USER}"
su - "${USER}" << __EOC__
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
WORKDIR "${USER_HOME}"
