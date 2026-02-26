#!/usr/bin/env bash

MDR_RA_SERVICE="opal-datashield.service"
MDR_RA_COMPOSE="datashield-opal-compose.yml"
MDR_RA_ENVFILE="datashield-opal-compose.env"
MDR_RA_UID=$(cat default_settings.yml custom_settings.yml | grep "datashield_uid:" | tail -n 1 | sed -e "s/^datashield_uid: //")
MDR_RA_USER=$(cat default_settings.yml custom_settings.yml | grep "datashield_uid:" | tail -n 1 | sed -e "s/^datashield_uid: //")
MDR_RA_NETWORK=$(cat default_settings.yml custom_settings.yml | grep "podman_network:" | tail -n 1 | sed -e "s/^podman_network: //")

export MDR_RA_SERVICE
export MDR_RA_COMPOSE
export MDR_RA_ENVFILE
export MDR_RA_UID
export MDR_RA_USER
export MDR_RA_NETWORK
