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

* A set of valid certificates (`privkey.pem`, `fullchain.pem`), if available,
  may be copied to the `cert/` directory in order to configure the NGINX HTTPS
  proxy. If no valid certificate files are provided, the  automation will
  create a set of self-signed certificates, stored in the
  `/home/mdr-ra/datashield_setup/https/cert` directory, to enable the HTTPS
  proxy service.

> [!CAUTION]
>
> For users opting to use self-signed certificates: while this will allow the
> service to establish encrypted connections, it cannot be considered a source
> of trust in any kind of public network. In order to expose the service to the
> public internet, users should acquire valid certificates from a trusted
> authority such as [Let's Encrypt](https://letsencrypt.org/) for a dedicated
> fully-qualified domain name.

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
#### 3. Configure your SSH client and server for public key authentication

For increased security and ease of use, SSH access to the server should be
configured to use key-based authentication instead of passwords. All the
following commands should be entered as a regular user, with no administrative
privileges.

##### **On the client machine**

If you do not already have an SSH key pair, create one by running the following
command on the client machine:

```bash
ssh-keygen -t ed25519 -a 100 -C "your_email@example.com"
```

When prompted, press Enter to accept the default location. You may set a
passphrase for extra security, but it's not mandatory. This procedure will
create a private key (`~/.ssh/id_ed25519`) and a public key
(`~/.ssh/id_ed25519.pub`). Only the latter should ever be made public or copied
anywhere.

Next, copy your public key to the target server:

```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub user@your-server-ip
```

If this command is not available on the client, you may proceed with the
server's configuration as described below.

##### **On the server**

If the `ssh-copy-id` command is not available on the client machine, you can
manually add the contents of your public key file to the
`~/.ssh/authorized_keys` file on the server. Create the `~/.ssh/` directory and
the `authorized_keys` file if not already present in the target user's home
directory.

After copying your key, make sure the permissions are set correctly on the
server side:

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

Once this is done, test the connection:

```bash
ssh user@your-server-ip
```

You should now be able to log in from the client using public key
authentication. If no passphrase was entered at the key creation step, the
client will login without being prompted for a password.

> [!CAUTION]
>
> Failure to properly configure either the SSH client or server for public key
> authentication may result in the user locking themselves (and others) out of
> the system. Please exercise caution during this phase and ensure the setup
> has been tested by following the recommended steps.

#### 4. Add a custom configuration file

A set of variables allows to customize the installation process according to
the requirements of the local environment. In the repository's root directory,
create a file called `custom_settings.yml`. At the very least, you should
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
`default_settings.yml`.

#### 5. Start the installation

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

> [!DANGER]
> The playbook allows to skip entirely all firewall configuration steps by
> adding the option `--skip-tags firewall` to the command line. This option is
> meant to be used only for testing or debugging purposes, and should *never*
> be included when launching the software in a production environment.


#### 6. Other methods to allow remote connections

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
with administrator privileges should access the `mdr-ra` user account with
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

Where possible, the system will rely on container images maintained by
[Bitnami](https://bitnami.com/application-catalog) for enhanced security.

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

### Security Notes

#### 2025-03-04

A review of the `pluribus_one/nginx-modsec` image using the Quay Security
Scanner on the Quay image repository reveals that, as of the date of this
writing, the image contains two critical vulnerabilities. These are identified
as CVE-2023-45853 and CVE-2023-38199.

* **CVE-2023-45853** is attributed to the presence of `zlib` in the base layer
  of the image, even though the actual vulnerability lies in the `minizip`
  product. Notably, `minizip` is not included in the final image, which suggests
  that this finding may be a result of a misinterpretation by the static
  analysis tool.

* **CVE-2023-38199** is introduced by the inclusion of the OWASP Core Rule Set
  (CRS) for ModSecurity. In brief, this vulnerability pertains to the potential
  for an attacker to bypass the Web Application Firewall (WAF), specifically
  ModSecurity in this case, through a highly specific type of attack involving
  Content-Type confusion between the WAF and the backend application.
  An application protected by a Web Application Firewall (WAF), even if
  potentially susceptible to a highly specific attack vector, is inherently
  less vulnerable than an application without any WAF protection. Therefore, we
  have made the informed decision to accept the risk associated with this
  particular vulnerability in our image, as the benefits of WAF protection
  outweigh the potential exposure.

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
