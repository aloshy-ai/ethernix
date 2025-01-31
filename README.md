# ETHERNIX

[![Built with Devbox](https://www.jetify.com/img/devbox/shield_galaxy.svg)](https://www.jetify.com/devbox/docs/contributor-quickstart/)
[![Build Status](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/aloshy-ai/YOUR_GIST_ID/raw/ethernix-junit-tests.json)](https://github.com/aloshy-ai/ethernix/actions/workflows/ci.yml)
[![Deployment Status](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/aloshy-ai/YOUR_GIST_ID/raw/ethernix-deployment.json)](https://github.com/aloshy-ai/ethernix/actions/workflows/ci.yml)
[![Apple Silicon Ready](https://img.shields.io/badge/Apple%20Silicon-Ready-success?logo=apple&logoColor=white)](https://github.com/aloshy-ai/ethernix)
[![Platform](https://img.shields.io/badge/platform-Darwin%20%7C%20Linux-blue)](https://github.com/aloshy-ai/ethernix)
[![Docker Support](https://img.shields.io/badge/Docker-Enabled-2496ED?logo=docker&logoColor=white)](https://github.com/aloshy-ai/ethernix)

A NixOS image builder for Raspberry Pi 4 that provides a streamlined way to create custom NixOS images. Works natively on Apple Silicon (M1/M2/M3) Macs through Docker-based cross-compilation, ensuring seamless build experience across platforms.

## Overview

ETHERNIX simplifies the process of creating NixOS images for Raspberry Pi 4 by providing:

- Declarative NixOS configuration specifically optimized for Raspberry Pi 4
- Automated build pipeline using Devbox
- Pre-configured networking and SSH access
- Essential system utilities pre-installed
- Reproducible builds through Nix
- Native support for Apple Silicon through Docker-based cross-compilation

## System Requirements

- [Devbox](https://www.jetify.com/docs/devbox/installing_devbox) installed
- Container runtime:
  - Docker Desktop or Colima with minimum 8GB RAM and 4 CPUs
- Hardware:
  - SD Card (minimum 8GB)
  - SD Card reader/writer
  - Raspberry Pi 4

## Quick Start

1. Clone and enter the repository:
   ```bash
   git clone https://github.com/aloshy-ai/ethernix.git
   cd ethernix
   ```

2. Initialize development environment:
   ```bash
   devbox shell
   ```
   For `direnv` users, run `direnv allow` instead.

3. Generate a secure password hash:
   ```bash
   ./scripts/passwdgen.sh
   ```

4. Configure the user account in `configuration.nix`:
   ```nix
   users.users.admin = {
     isNormalUser = true;
     extraGroups = [ "wheel" ];
     hashedPassword = "your-generated-hash-here";
   };
   ```

5. Build the image:
   ```bash
   devbox run build
   ```

## SD Card Installation

1. Identify your SD card:
   ```bash
   diskutil list
   ```

2. Prepare the SD card:
   ```bash
   sudo diskutil unmountDisk /dev/diskN
   ```
   > Replace `diskN` with your SD card's identifier (e.g., `disk6`)

3. Flash the image:
   ```bash
   sudo dd if=out/ethernix.img of=/dev/diskN bs=1M status=progress
   ```
   > ⚠️ **CAUTION**: Double-check the disk identifier to prevent data loss

4. Safely eject:
   ```bash
   sudo sync
   sudo diskutil eject /dev/diskN
   ```

## Initial Setup

1. Insert the SD card and connect your Raspberry Pi 4 to:
   - Power supply
   - Ethernet cable
   - (Optional) Display and keyboard for direct access

2. Access via SSH:
   ```bash
   ssh aloshy@192.168.8.69
   ```

3. Update system channels:
   ```bash
   sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos
   sudo nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
   sudo nix-channel --update
   ```

4. Set up system configuration:
   ```bash
   sudo nixos-generate-config
   ```

5. Transfer configuration files:
   
   From your development machine:
   ```bash
   scp -i ~/.ssh/id_rsa {flake.nix,configuration.nix} aloshy@192.168.8.69:/tmp/
   ```

   On the Raspberry Pi:
   ```bash
   sudo mv /tmp/{flake.nix,configuration.nix} /etc/nixos/
   ```

6. Apply the configuration:
   ```bash
   sudo nixos-rebuild switch -I nixos-config=/etc/nixos/flake.nix
   ```

## Default Configuration

- User Account: `aloshy`
- Network: Static IP `192.168.8.69`
- Services: SSH enabled
- Core Utilities: vim, wget, and essential tools

## Auto-Deployment Setup

ETHERNIX supports automatic deployment using GitHub Actions and Tailscale. This allows you to automatically deploy configuration changes to your Raspberry Pi when changes are pushed to the main branch.

### Prerequisites

1. A Tailscale account and network
2. GitHub repository secrets configured
3. Your Raspberry Pi connected to Tailscale

### Setup Steps

1. Connect your Raspberry Pi to Tailscale:
   ```bash
   sudo tailscale up --ssh --advertise-exit-node
   ```

2. Configure GitHub repository secrets:
   - `TAILSCALE_OAUTH_CLIENT_ID`: Your Tailscale OAuth client ID
   - `TAILSCALE_OAUTH_CLIENT_SECRET`: Your Tailscale OAuth client secret
   - `TAILSCALE_TAILNET`: Your Tailscale network name

3. Ensure your `configuration.nix` includes Tailscale service:
   ```nix
   services.tailscale = {
     enable = true;
     authKeyFile = "/etc/tailscale/authkey";
     extraUpFlags = [
       "--ssh"
       "--advertise-exit-node"
     ];
   };

   # Add runner user for GitHub Actions
   users.users.runner = {
     isNormalUser = true;
     extraGroups = [ "wheel" ];
   };
   ```

4. The CI workflow will:
   - Connect to your Tailscale network
   - Verify device connectivity
   - Deploy configuration changes
   - Automatically rebuild NixOS on your Raspberry Pi

### Deployment Process

1. Push changes to the main branch
2. GitHub Actions will:
   - Build and verify changes
   - Connect to your Tailscale network
   - Update ACL policies
   - Deploy to devices tagged with `tag:ci`
   - Rebuild NixOS configuration

### Monitoring Deployments

- Check deployment status in the GitHub Actions tab
- Monitor Tailscale device status in your admin console
- View deployment logs for troubleshooting

### Security Considerations

- The CI runner has limited permissions through Tailscale ACLs
- Deployments only run on the main branch
- Configuration changes require successful builds
- Remote access is secured through Tailscale's encryption

## Customization

The system can be customized by modifying `