#!/usr/bin/env bash

source /etc/os-release

source utils/get_env.sh

if [ "$ID" = "ubuntu" ] && [ "$VERSION_ID" = "22.04" ]; then
    :
elif [ "$ID" = "ubuntu" ] && [ "$VERSION_ID" = "24.04" ]; then
    :
elif [ "$PLATFORM_ID" = "platform:el9" ]; then
    :
else
    echo "Unsupported distribution: $PRETTY_NAME"
    exit 1
fi

sudo machinectl shell --uid "$MDR_RA_UID" "$MDR_RA_USER"@.host $(which bash)
