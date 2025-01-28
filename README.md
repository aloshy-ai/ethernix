# ETHERNIX

EtherNix is a NixOS Image builder for Raspberry Pi 4.

## Getting Started

### Prerequisites

- Devbox: Install [Devbox](https://www.jetify.com/docs/devbox/installing_devbox) for your OS.
- Docker Daemon: Docker Desktop or Colima running in the background with at least 8GB of RAM and 4 CPUs.
- Executable permission for the `build.sh` and `passwdgen.sh` scripts.

### Enter the Devbox Shell

```bash
devbox shell
```

> If you're already using `direnv`, and have it's hook added to your shell, you'll need to run `direnv allow` to allow the devbox environment to be activated automatically as you enter the directory.

### Configuration

Use `passwdgen.sh` to generate a hashed password and replace it in `configuration.nix`.
Additionally, you can modify the username and hostname in `configuration.nix`.

### Building the Builder

```bash
docker build --no-cache -t ethernix-builder .
```

### Running the Builder

```bash
docker run --rm -it -v "$(pwd):/build" --platform linux/arm64 ethernix-builder sh -c "./build.sh"
```


