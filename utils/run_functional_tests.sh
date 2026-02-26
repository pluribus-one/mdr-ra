#!/usr/bin/env bash

source /etc/os-release

source utils/get_env.sh

CONTAINER_IMAGE="docker.io/pluribusone/mdr-ra-functional-tests:latest"
DEPLOYED_CA_DIRECTORY="/opt/mdr-ra/https/ca"
LOCAL_CA_DIRECTORY=$(readlink -f ./ca)
LOCAL_DEPLOYMENT="false"

if sudo test -d "$DEPLOYED_CA_DIRECTORY"; then
    LOCAL_DEPLOYMENT="true"

    echo "Testing a local DataSHIELD installation"
    printf "\n"
    OPT_MOUNT_CA_VOLUME="--volume $DEPLOYED_CA_DIRECTORY:/usr/local/share/ca-certificates/mdr-ra:Z "

    echo "Configuring CA certificates: OPAL"
    printf "\n"
    sudo machinectl shell --uid "$MDR_RA_UID" "$MDR_RA_USER"@.host $(which bash) \
        -c "podman exec --interactive --tty mdr-ra-opal-server-opal update-ca-certificates"
    printf "\n"

    echo "Configuring CA certificates: Rock"
    printf "\n"
    sudo machinectl shell --uid "$MDR_RA_UID" "$MDR_RA_USER"@.host $(which bash) \
        -c "podman exec --interactive --tty mdr-ra-rock-rock update-ca-certificates"
    printf "\n"
else
    echo "Testing a remote DataSHIELD installation"
    printf "\n"

    if test -d "$LOCAL_CA_DIRECTORY"; then
        OPT_MOUNT_CA_VOLUME="--volume $LOCAL_CA_DIRECTORY:/usr/local/share/ca-certificates/mdr-ra:Z "
    else
        OPT_MOUNT_CA_VOLUME=""
    fi
fi

TEST_URL="${DATASHIELD_URL:-https://mdr-ra:8000}"

if [ "$TEST_URL" = "https://datashield.local:4443" ]; then
    echo "Testing on podman network: $MDR_RA_NETWORK"
    printf "\n"

    OPT_NETWORK="--network $MDR_RA_NETWORK "
else
    OPT_NETWORK=""
fi

echo "Testing DataSHIELD installation at URL: $TEST_URL"
printf "\n"

PODMAN_TEST_CMD="podman run --rm --pull newer $OPT_NETWORK $OPT_MOUNT_CA_VOLUME $CONTAINER_IMAGE $TEST_URL"

if [ "$LOCAL_DEPLOYMENT" = "false" ]; then
    $(which bash) -c "$PODMAN_TEST_CMD"
else
    sudo machinectl shell --uid "$MDR_RA_UID" "$MDR_RA_USER"@.host \
        $(which bash) -c "$PODMAN_TEST_CMD"
fi
