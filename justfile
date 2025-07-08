mdr-ra-service := "opal-datashield.service"
mdr-ra-uid := `cat default_settings.yml custom_settings.yml | grep "datashield_uid:" | tail -n 1 | sed -e "s/^datashield_uid: //"`
mdr-ra-user := `cat default_settings.yml custom_settings.yml | grep "datashield_uid:" | tail -n 1 | sed -e "s/^datashield_uid: //"`


# Inspect the status of the running DataSHIELD service
status:
    @machinectl shell --uid {{mdr-ra-uid}} {{mdr-ra-user}}@.host $(which bash) -c "systemctl --user status --no-pager {{mdr-ra-service}}"

# Stop the DataSHIELD service
stop:
    @machinectl shell --uid {{mdr-ra-uid}} {{mdr-ra-user}}@.host $(which bash) -c "systemctl --user stop {{mdr-ra-service}}"

# Restart the DataSHIELD service
start:
    @machinectl shell --uid {{mdr-ra-uid}} {{mdr-ra-user}}@.host $(which bash) -c "systemctl --user restart {{mdr-ra-service}}"

# Install DataSHIELD exposing Opal as an HTTPS service
install:
    @ansible-playbook --ask-become-pass --tags public_ip playbook.yml

# Install DataSHIELD without exposing any HTTPS service
install-no-https:
    @ansible-playbook --ask-become-pass playbook.yml

# Enter a system shell with the user running the DataSHIELD service
enter-shell:
    @machinectl shell --uid {{mdr-ra-uid}} {{mdr-ra-user}}@.host $(which bash)
