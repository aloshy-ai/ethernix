# #!/usr/bin/env bash

nix run nixpkgs#nixos-generators -- -f sd-aarch64 --flake .#ethernix --system aarch64-linux -o ./ethernix.sd
