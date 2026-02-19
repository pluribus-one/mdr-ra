#!/usr/bin/env bash

source /etc/os-release

source utils/get_env.sh

if [ "$ID" = "ubuntu" ] && [ "$VERSION_ID" = "24.04" ]; then
    sudo machinectl shell --uid "$MDR_RA_UID" "$MDR_RA_USER"@.host $(which bash) \
        -c "systemctl --user status --no-pager $MDR_RA_SERVICE"
elif [ "$PLATFORM_ID" = "platform:el9" ]; then
    sudo machinectl shell --uid "$MDR_RA_UID" "$MDR_RA_USER"@.host $(which bash) \
        -c "systemctl --user status --no-pager $MDR_RA_SERVICE"
else
    echo "Unsupported distribution: $PRETTY_NAME"
    exit 1
fi
