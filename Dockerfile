FROM ubuntu:20.04 as build-env
LABEL uk.org.lsuves.image.authors="Aidan Brooks"
LABEL uk.org.lsuves.image.info="SCP: Secret Lab Server - Build Environment"
USER root
# # CONFIGURE ENVIRONMENT
# # --------------------------------------------------
# Set to debug mode
# Install tools required
# Download appropriate libicu version for the main image

RUN set -x

RUN apt-get update --no-install-recommends --no-install-suggests \
    && apt-get install -y \
        wget \
        ca-certificates \
        lib32stdc++6 \
        lib32gcc1 

RUN wget 'http://ftp.us.debian.org/debian/pool/main/i/icu/libicu63_63.1-6+deb10u3_amd64.deb' \
    && dpkg -i libicu63_63.1-6+deb10u3_amd64.deb

# # END CONFIGURE ENV
# # --------------------------------------------------


# # SETUP USER & GROUP
# # --------------------------------------------------

RUN groupadd -rg 22035 setup \
    && useradd setup -g 22035 -m

USER setup
WORKDIR /home/setup

# # END SETUP
# # --------------------------------------------------


# # INSTALL STEAMCMD
# # --------------------------------------------------

RUN mkdir ~/steamcmd \
    && cd ~/steamcmd \
    && wget -qO- 'https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz' | tar zxf -

# # END INSTALL STEAMCMD
# # --------------------------------------------------


# # INSTALL SCP SECRET LAB DEDICATED SERVER
# # --------------------------------------------------

RUN mkdir ~/scp

RUN ~/steamcmd/steamcmd.sh \
    +login "anonymous" \
    +force_install_dir ~/scp \
    +app_update "996560" validate \
    +quit

RUN mkdir -p ~/scp/servers/server1

# # END INSTALL SCP:SL
# # --------------------------------------------------


# # PULL EXILED INSTALLER
# # --------------------------------------------------
# Gets installer EXILED from releases
# Sets executable permission

RUN cd ~/scp \
    && wget --no-check-certificate 'https://github.com/Exiled-Team/EXILED/releases/latest/download/Exiled.Installer-Linux' \
    && chmod +x Exiled.Installer-Linux \
    && ./Exiled.Installer-Linux

# # END EXILED
# # --------------------------------------------------


FROM ubuntu:20.04 as runtime-env 
LABEL uk.org.lsuves.image.authors="Aidan Brooks"
LABEL uk.org.lsuves.image.info="SCP: Secret Lab Server - Runtime Environment"
USER root
# # CONFIGURE ENVIRONMENT
# # --------------------------------------------------

RUN apt-get update --no-install-recommends --no-install-suggests \
    && apt-get install -y \
        ca-certificates

COPY --from=build-env /libicu63_63.1-6+deb10u3_amd64.deb /libicu63_63.1-6+deb10u3_amd64.deb
RUN dpkg -i libicu63_63.1-6+deb10u3_amd64.deb

# # END CONFIGURE ENV
# # --------------------------------------------------


# # CREATE MOUNTPOINTS
# # --------------------------------------------------
# Base level config directory for .config file mountpoint

RUN mkdir /config \
    && chown 22035 /config

# # END MOUNTPOINTS
# # --------------------------------------------------


# # SETUP USER & GROUP
# # --------------------------------------------------

RUN groupadd -rg 22035 manager \
    && useradd manager -g 22035 -m
USER manager:22035
WORKDIR /home/manager

# # END SETUP
# # --------------------------------------------------


# # RESOURCE ACCESS
# # --------------------------------------------------
# Copy across relevant files from the build-env
# Symlink top level config directory

COPY --from=build-env --chown=manager:22035 \
    /home/setup/scp \
    /home/manager/server

RUN ln -s /config ~/.config \
    && ln -s /config ~/config

# # END RESOURCE
# # --------------------------------------------------


# # START SERVER
# # --------------------------------------------------
# BAD DOOBIE USE GITHUB

ADD --chown=manager:22035 entrypoint.sh .

ENV SCPSL_PORT=7777

ENV EXILED_INSTALLER_ENABLED="true"
ENV EXILED_INSTALLER_FORCED="false"

CMD ["./entrypoint.sh"]

# # END START
# # --------------------------------------------------