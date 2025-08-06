#!/usr/bin/env bash

source /etc/os-release

source utils/get_env.sh

if [ "$ID" = "ubuntu" ] && [ "$VERSION_ID" = "22.04" ]; then
    machinectl shell --uid "$MDR_RA_UID" "$MDR_RA_USER"@.host $(which bash) \
        -c "cd /opt/mdr-ra && docker compose --env-file $MDR_RA_ENVFILE --file $MDR_RA_COMPOSE down"
elif [ "$ID" = "ubuntu" ] && [ "$VERSION_ID" = "24.04" ]; then
    machinectl shell --uid "$MDR_RA_UID" "$MDR_RA_USER"@.host $(which bash) \
        -c "systemctl --user stop $MDR_RA_SERVICE"
elif [ "$PLATFORM_ID" = "platform:el9" ]; then
    machinectl shell --uid "$MDR_RA_UID" "$MDR_RA_USER"@.host $(which bash) \
        -c "systemctl --user stop $MDR_RA_SERVICE"
else
    echo "Unsupported distribution: $PRETTY_NAME"
    exit 1
fi
