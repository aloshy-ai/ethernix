# ETHERNIX

[![Built with Devbox](https://www.jetify.com/img/devbox/shield_galaxy.svg)](https://www.jetify.com/devbox/docs/contributor-quickstart/)
[![CI](https://github.com/aloshy-ai/ethernix/actions/workflows/ci.yml/badge.svg)](https://github.com/aloshy-ai/ethernix/actions/workflows/ci.yml)

A NixOS image builder for Raspberry Pi 4.

## Features

- Custom NixOS configuration for Raspberry Pi 4
- Automated build process using Devbox
- Pre-configured network settings
- SSH enabled by default
- Basic system tools included

## Prerequisites

- [Devbox](https://www.jetify.com/docs/devbox/installing_devbox)
- Docker Desktop or Colima (8GB RAM, 4 CPUs minimum)
- SD Card (8GB minimum)
- SD Card reader/writer

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/aloshy-ai/ethernix.git
   cd ethernix
   ```

2. Enter the Devbox shell:
   ```bash
   devbox shell
   ```
   > **Note**: If using `direnv`, run `direnv allow` to activate the environment automatically.

3. Generate a password hash:
   ```bash
   ./passwdgen.sh
   ```

4. Update the configuration:
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

## Writing to SD Card

1. List available disks:
   ```bash
   diskutil list
   ```

2. Unmount the target disk:
   ```bash
   sudo diskutil unmountDisk /dev/diskN
   ```

3. Write the image:
   ```bash
   sudo dd if=out/ethernix.img of=/dev/diskN bs=1M status=progress
   ```
   > ⚠️ **Warning**: Verify the disk identifier carefully to avoid data loss.

4. Finalize:
   ```bash
   sudo sync
   sudo diskutil eject /dev/diskN
   ```

## Usage

1. Insert SD card into Raspberry Pi 4
2. Connect ethernet cable
3. Power on the device
4. Connect via SSH:

   ```bash
   ssh aloshy@192.168.8.69
   ```

5. Generate NixOS configuration:

   ```bash
   sudo nixos-generate-config
   ```

6. Update Nix Channel:

   ```bash
   sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos
   sudo nix-channel --update
   ```

7. Copy the configuration file:

   On your local machine:
   ```bash
   scp configuration.nix aloshy@192.168.8.69:/tmp/configuration.nix
   ```

   On the Raspberry Pi:
   ```bash
   sudo mv /tmp/configuration.nix /etc/nixos/configuration.nix
   ```

8. Apply the configuration:

   ```bash
   sudo nixos-rebuild switch -I nixos-config=/etc/nixos/configuration.nix
   ```

## Default Configuration

- Username: `aloshy`
- IP Address: `192.168.8.69`
- SSH: Enabled
- Included packages: vim, wget, and other basic utilities

## Customization

Edit `configuration.nix` to modify:
- Username
- Hostname
- Network settings
- Package selection

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
