## 2025-06-13

* Fixed hostname reference for the PostgreSQL container
* Removed MongoDB from the containerized environment
* Removed MongoDB references from the documentation

## 2025-06-11

* Revert to using 443 as the default port for the HTTPS service. The port is
  now configurable
* Extended documentation for the setup of custom HTTPS certificates
* Documentation: fixed name for the DataSHIELD-Rock container
* Documentation: various fixes

## 2025-06-09

* Added a test to stop the service during the Playbook's execution, if already
  running
* Fixed permissions for database directories
* Fixed restart policies for database services
* Reverted to the original `rock-omics2` image for stability
* Updated the documentation to reflect the latest changes

## 2025-05-06

* Migrated to a Quadlet-based service management for better integration with
  the system
* Removed MySQL from the set of required database servers
* NGINX now includes a fully configured ModSecurity WAF module with the OWASP
  Core Rule Set preinstalled
* Refactored the specification of the `rock-omics2` container image in order to
  reduce its size and accelerate deployment and testing operations
* Fixed permissions for the deployment of database container volumes
* Fixed missing dependencies for the Ansible Playbook specification
* Fixed inconsistencies between the Ansible Playbook and Podman Kube
  specifications
* Updated documentation

## 2025-03-13

* Allow users to install a set of HTTPS certificates
* Added an optional "no firewall" tag for debugging purposes
* The default username for the containerized deployment is now `mdr-ra`

## 2025-03-04

* Improved path specification and creation procedures for Opal and other data
  persistence modules
* Updated security evaluation notes for container images

## 2025-02-28

* Initial release
