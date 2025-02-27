# MDR-RA

This document defines updated setup instructions for secure deployments of the
DataSHIELD/Opal environment required by the MDR-RA project.

## Operating System

The recommended operating system for the automated environment setup, as
outlined by the source files in this repository, is the server edition of
[Ubuntu 24.04 LTS](https://ubuntu.com/download/server). It is highly advised
that users install this operating system in a dedicated virtual machine to
enhance isolation from other applications and users on the local network, as
well as to streamline deployment and maintenance processes.

## Deployment Criteria

The following principles have been followed during the development of this
guide and related files:

* **Automation:** We aim to implement a reproducible and verifiable environment
  using automated setup and maintenance tools.
* **Containerization**: The procedure will instal the system as an orchestrated
  containerized environment using the Podman platform. The daemonless and
  rootless architecture implemented by Podman offers better security and
  stability compared to systems relying on the execution of a single background
  process.
* **Verified Container Images**: Container images with known, documented
  vulnerabilities won't be included in the system specification files.
* **System Hardening**: The automation will configure the Ubuntu 24.04 server
  performing some system hardening where necessary. No ports will be exposed
  for the Opal application service unless explicitly requested by the user.

Please note that after the setup is complete, SSH access will be available only
through public key authentication. If remote access for system administration
tasks is required, public SSH keys of authorized users must be added to the
`.ssh/authorized_keys` file before proceeding with the setup steps.

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
port 22. This can be achieved by entering a setting similar to the following
example in the new file:

```yaml
---
allowed_ssh_client_networks:
  - 192.168.1.55/32
  - 192.168.2.0/24
```

For a complete overview of available settings, refer to the contents of
`default-settings.yml`.

#### 3. Start the installation

For a standard, non-public installation, use the following command. Please note
that the user should be within the root directory of this repository:

```bash
ansible-playbook --ask-become-pass playbook.yml
```

You will be immediately prompted for your password, required to perform system
administration tasks. If the service port should be exposed on a public IP, add
the `public_ip` tag to the command line options:

```bash
ansible-playbook --ask-become-pass --tags public_ip playbook.yml
```

This will add a firewall rule to allow incoming connections on port `8000`. A
rate limiting rule will also be added to mitigate possible Brute Force and DDoS
attacks.

### 4. Allowing remote connections

If the installation has been performed without exposing the service on a public
IP address, a VPN connection is the recommended method to allow clients to
connect to the server. If no dedicated services are available,
[Tailscale](https://tailscale.com/) provides a quick alternative for
the deployment of
