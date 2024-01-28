#! /bin/bash

(
    cd ./server
    [ "$EXILED_INSTALLER_ENABLED" = "true" ] && [ ! -e "../config/SCP Secret Laboratory/PluginAPI/plugins/global/Exiled.Loader.dll" -o "$EXILED_INSTALLER_FORCE" = "true" ] \
        && ./Exiled.Installer-Linux
    ./LocalAdmin $SCPSL_PORT
)
