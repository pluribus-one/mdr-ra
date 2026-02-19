#!/usr/bin/env bash

source /etc/os-release

source utils/get_env.sh

CONTAINER_IMAGE="docker.io/pluribusone/mdr-ra-functional-tests:latest"
LOCAL_CA_DIRECTORY="/opt/mdr-ra/https/ca"

if sudo test -d "$LOCAL_CA_DIRECTORY"; then
    echo "Testing a local DataSHIELD installation"
    printf "\n"
    OPT_MOUNT_CA_VOLUME="--volume $LOCAL_CA_DIRECTORY:/usr/local/share/ca-certificates/mdr-ra:Z "

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
    OPT_MOUNT_CA_VOLUME=""
fi

TEST_URL="${DATASHIELD_URL:-https://mdr-ra:8000}"

echo "Testing DataSHIELD installation at URL: $TEST_URL"
printf "\n"

PODMAN_TEST_CMD="podman run --rm --pull newer $OPT_MOUNT_CA_VOLUME $CONTAINER_IMAGE $TEST_URL"

sudo machinectl shell --uid "$MDR_RA_UID" "$MDR_RA_USER"@.host $(which bash) \
    -c "$PODMAN_TEST_CMD"
