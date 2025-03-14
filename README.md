# ETHERNIX

[![](https://img.shields.io/badge/aloshy.🅰🅸-000000.svg?style=for-the-badge)](https://aloshy.ai)
[![Platform](https://img.shields.io/badge/PLATFORM-LINUX-FCC624.svg?style=for-the-badge&logo=linux)](https://github.com/aloshy-ai/ethernix)
[![Build Status](https://img.shields.io/badge/BUILD-PASSING-success.svg?style=for-the-badge&logo=github)](https://github.com/aloshy-ai/ethernix/actions)
[![Apple Silicon Ready](https://img.shields.io/badge/APPLE_SILICON-READY-success.svg?style=for-the-badge&logo=apple)](https://github.com/aloshy-ai/ethernix)
[![License](https://img.shields.io/badge/LICENSE-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

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
   ```
