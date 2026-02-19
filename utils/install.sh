#!/usr/bin/env bash

source /etc/os-release

if [ "$ID" = "ubuntu" ] && [ "$VERSION_ID" = "24.04" ]; then
    PLAYBOOK_FILE="playbook-ubuntu2404.yml"
elif [ "$PLATFORM_ID" = "platform:el9" ]; then
    PLAYBOOK_FILE="playbook-rhel9.yml"
else
    echo "Unsupported distribution: $PRETTY_NAME"
    exit 1
fi

echo "Detected supported distribution: $PRETTY_NAME"
echo "Executing playbook: $PLAYBOOK_FILE"

ansible-playbook --ask-become-pass --tags public_ip "$PLAYBOOK_FILE"
