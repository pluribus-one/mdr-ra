# MDR-RA DataSHIELD/Opal Environment Setup

This document defines updated setup instructions for hardened deployments of
the DataSHIELD/Opal environment required by the MDR-RA project.

#### Contents

* [Operating System](#operating-system)
* [Deployment Notes](#deployment-notes)
* [Installation](#installation)
* [Setup and Usage](#setup-and-usage)
* [System Maintenance](#system-maintenance)
* [Container Releases](#container-releases)
* [Security Assessments](#security-assessments)
* [External Resources](#external-resources)



## Operating System

The recommended operating system for the automated environment setup, as
outlined by the source files in this repository, is the server edition of
[Ubuntu 24.04 LTS](https://ubuntu.com/download/server). It is highly advised
that users install this operating system in a dedicated virtual machine to
enhance isolation from other applications and users on the local network, as
well as to streamline deployment and maintenance processes.


## Deployment Notes

The following notes outline the criteria and steps implemented by this
installation procedure.

* The setup has been fully automated using the open source
  [Ansible](https://docs.ansible.com/) tool to implement software provisioning
  and configuration using an infrastructure-as-code (IaC) approach. This will
  ensure that software deployments are fully reproducible and verifiable on
  a common platform, and provide a base to extend and update the system's
  specification for the duration of the project with safe and documented
  upgrade procedures.

* The operating system will be configured to install automatic security
  upgrades from the official Ubuntu Linux repositories.

> [!WARNING]
> Automatic reboots won't
> be activated in order to avoid possible service disruptions, but server
> administrators are advised to restart the system regularly to ensure kernel
> security updates are effective.

* The Docker-based containerization solution has been replaced with a
  [Podman](https://podman.io/)-based equivalent specification, in order to
  have the system running in rootless mode with contained privileges. Podman
  is a daemonless container management system, enabling users to control
  containerized applications directly and resulting in enhanced security and
  faster container execution times.

* A dedicated user will be configured by the automated setup procedure to
  execute the containerized environment. This account won't have any
  administrative privileges, and there is no need for application users and
  clients to have access to its environment.

* The system specification files will only include container image references
  with no known vulnerabilities. Users are encouraged to monitor this
  repository for updates to the list of approved software versions.

* The SSH server will be reconfigured to disable password-based authentication.
  After the completion of the setup procedure, SSH access will be available
  only through public key authentication.

> [!CAUTION]
>
> If remote access for system
> administration tasks is required, public SSH keys of authorized users must
> be added to the `.ssh/authorized_keys` file before proceeding with the setup
> steps.

* The automation will set up the system firewall
  ([UFW](https://help.ubuntu.com/community/UFW)) to block incoming connections.
  Services won't be exposed on available network interfaces unless explicitly
  requested by the user, and only for a limited set of trusted networks or
  hosts. Refer to the sections below for setup and configuration steps.

* The automation will create a set of self-signed certificates, stored in the
  `/home/datashield/datashield_setup/https/cert` directory, to enable the HTTPS
  proxy service.

> [!CAUTION]
>
> While this will allow the service to establish encrypted
> connections, it cannot be considered a source of trust in any kind of
> public network. In order to expose the service to the public internet,
> users should acquire valid certificates from a trusted authority such as
> [Let's Encrypt](https://letsencrypt.org/) for a dedicated fully-qualified
> domain name.

* The Opal web interface is exposed through a dedicated NGINX server
  functioning as a HTTPS reverse proxy with the ModSecurity web application
  firewall module enabled. This firewall is configured to enforce the
  well-known core rule set of application layer rules defined by the
  [OWASP](https://owasp.org/www-project-modsecurity-core-rule-set/) project.
  The container image providing this implementation of NGINX is published and
  maintained directly by Pluribus One.


## Installation

The following steps must be performed on the `bash` shell, either using the
virtualization hypervisor's console or within a terminal emulator logged in via
SSH. System administration privileges are required (the user must be authorized
to use `sudo`).

#### 1: Prerequisites

The automated installation require the presence of Git and Ansible tools on the
target system:

```bash
sudo apt-get install git ansible
```

#### 2. Clone this repository

Obtain the files hosted within this repository by typing in a terminal:

```bash
git clone https://github.com/pluribus-one/mdr-ra.git
```

#### 3. Add a custom configuration file

A set of variables allows to customize the installation process according to
the requirements of the local environment. In the repository's root directory,
create a file called `custom-settings.yml`. At the very least, you should
select the set of networks which will be allowed to reach the SSH server on
port 22. This can be achieved by entering settings similar to the following
example in the newly created file:

```yaml
---
allowed_ssh_client_networks:
  - 192.168.1.55/32
  - 192.168.2.0/24
```

For a complete overview of available options, refer to the contents of
`default-settings.yml`.

#### 4. Start the installation

For a standard installation with no exposed HTTPS service, enter the following
command at the shell prompt within the root directory of this repository:

```bash
ansible-playbook --ask-become-pass playbook.yml
```

You will be immediately prompted for your password, which is required to
perform system administration tasks. If the HTTPS service port should be
exposed on a public IP, add the `public_ip` tag to the command line options:

```bash
ansible-playbook --ask-become-pass --tags public_ip playbook.yml
```

This will add a firewall rule to allow incoming connections on port `8000`. A
rate limiting rule will also be added to mitigate possible Brute Force and DDoS
attacks.

#### 5. Other methods to allow remote connections

If the installation has been performed without exposing the service on a public
IP address, a VPN connection is the recommended method to allow clients to
connect to the server. If the organization hosting the server does not offer
dedicated VPN services, [Tailscale](https://tailscale.com/) is a reliable and
quick alternative for establishing a dedicated point-to-point connection.


## Setup and Usage

For detailed information about how to configure and use the software, please
refer to the documentation published by the team at UniVr:

[InfOmics/MDR-RA-Opal-DataSHIELD-documentation](https://github.com/InfOmics/MDR-RA-Opal-DataSHIELD-documentation/)


## System Maintenance

The automated procedure outlined above will pull all required container images
and start the system as configured. To perform administrative tasks, in order
to start and stop the orchestrated system using `podman`, users
with administrator privileges should access the `datashield` user account with
the following command:

```bash
sudo machinectl shell --uid 1090
```

The system can then be stopped using:

```bash
podman kube down datashield_setup/datashield-opal-kube.yml
```

And restarted with `podman kube play`:

```bash
podman kube play datashield_setup/datashield-opal-kube.yml
```


## Container Releases

This table lists the software releases accepted for inclusion in the
containerized system specification:

| Software                           | Current Verified Release                     |
| -------------                      | -------------                                |
| Opal                               | `docker.io/obiba/opal:5.1.2`                 |
| MySQL                              | `docker.io/bitnami/mysql:8.4.4`              |
| MongoDB                            | `docker.io/bitnami/mongodb:8.0.5`            |
| PostgreSQL                         | `docker.io/bitnami/postgresql:17.4.0`        |
| DataSHIELD / rock / dsOmics / dsML | `docker.io/infomics/rock-omics2:latest`      |
| NGINX                              | `quay.io/pluribus_one/nginx-modsec:1.27.0-0` |


## Security Assessments

The HTTP service was scanned using the PostSwigger Burp Suite Professional for
possible vulnerabilities. Manual checks were performed where necessary to
verify the outcome of automated assessment procedures. No significant
vulnerabilities were identified.


## External Resources

Additional information about DataSHIELD and Opal is available at the following
links:

* [Automated Disclosure Checks in DataSHIELD](https://wiki.datashield.org/en/statdev/disclosure-checks)
* [DataSHIELD R Interface (DSI)](https://isglobal-brge.github.io/resource_bookdown/datashield.html#datashield-r-interface-dsi)
* [Disclosure Control](https://wiki.datashield.org/en/opmanag/disclosure-control)
* [Privacy Control Level](https://wiki.datashield.org/en/opmanag/privacy-control-level)
