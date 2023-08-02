# VSCode Dev Container with Features in an Enterprise Environment
- **THIS PROJECT ONLY EXISTS TO SHOW A SOLUTION TO [microsoft/vscode-remote-release #7150](https://github.com/microsoft/vscode-remote-release/issues/7150)**
- **NO SUPPORT WILL BE PROVIDED**

This repo shows how you can use VSCode, Dev Containers, & Features in an enterprise environment that requires Custom ROOT CA Certificates.

This repository also contains a sample Dev Container for easily testing in your environment.

## Pre-Prerequisites

| Software   | Version
|----------|:-------------:|
| WSL |    v2   |
| VSCode |  >=1.80.0 |
| Dev Containers Extension |  v0.299.0 |
| Ubuntu WSL Instance | 20.04 or 22.04 |

## How To

The How-To instructions are split into two sections. Section 1 is performed within WSL and Section 2 is performed within Windows.

# Section 1: WSL

1. Open up a terminal in your Ubuntu WSL2 instance

2. Ensure that a copy of your Enterprise Root CA Certificates are in `/usr/local/share/ca-certificates/`. If you don't have the Root CA certs easily available you can use `./devContainer/createCerts.sh` or these commands to get them and load them into Ubuntu:

    ```bash
    sudo openssl s_client -showcerts -verify 5 -connect wikipedia.org:443 < /dev/null | awk '/BEGIN/,/END/{ if(/BEGIN/){a++}; out="cert"a".crt"; print >out}'; echo "Certificates:"; for cert in *.crt; do newname=$(openssl x509 -noout -subject -in $cert | sed -nE 's/.*CN ?= ?(.*)/\1/; s/[ ,.*]/_/g; s/__/_/g; s/_-_/-/; s/^_//g;p' | tr '[:upper:]' '[:lower:]').crt; echo "${newname}"; mv "${cert}" "/usr/local/share/ca-certificates/${newname}"; done
    sudo rm /usr/local/share/ca-certificates/wikipedia_org.crt
    sudo update-ca-certificates
    ```

3. Configure your profile to set NODE_XTRA_CA_CERTS. This can be done in multiple ways, such as `~/.profile`, `~/.zprofile`, `~/.zshrc`, and others. The way I did this was to actually create `/etc/profile.d/node_certs.sh` (make sure to chmod +x) with the following script:

    ```bash
    #!/bin/bash

    export NODE_EXTRA_CA_CERTS=/etc/nodecerts.pem
    ```

4. Copy `/etc/nodecerts.pem` to `/mnt/c/temp/nodecerts.pem`
    ```bash
    mkdir /mnt/c/temp/
    cp /etc/nodecerts.pem /mnt/c/temp/nodecerts.pem
    ```

# Section 2: Windows

Before starting this section, take `c:\temp\nodecerts.pem` and place it wherever you wish. For the purposes of these instructions we're going to assume that the file remains in `c:\temp\`

1. Set a system environment variable named `NODE_EXTRA_CA_CERTS` and set the value to `c:\temp\nodecerts.pem`
2. Close VSCode & any Terminal Windows

# Section 3: Testing

You can now test this out for yourself. This should work natively in Windows as well as inside of your Ubuntu WSL instance. I recommend using WSL for all repositories due to a variety of issues with mounting local paths into containers. See [here](https://docs.docker.com/desktop/troubleshoot/topics/#topics-for-windows), [here](https://github.com/docker/for-win/issues/6742), [here](https://github.com/microsoft/WSL/issues/873) & [here](https://github.com/microsoft/WSL/issues/4197).

1. Open repository in VSCode and then tell VSCode to open in Dev Container.
2. You can verify it succeeded by running `terraform --version`, which is the single feature being installed by this repo.