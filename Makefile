playbook_ubuntu2204 = playbook-ubuntu2204.yml
playbook_ubuntu2404 = playbook-ubuntu2404.yml
playbook_rhel9      = playbook-rocky9.yml


install:
	@utils/install.sh

status:
	@utils/status.sh

stop:
	@utils/stop.sh

start:
	@utils/start.sh

shell:
	@utils/shell.sh
