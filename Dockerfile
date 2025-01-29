FROM nixos/nix

# Install git which is needed for flakes
RUN nix-channel --update
RUN nix-env -iA nixpkgs.git nixpkgs.busybox nixpkgs.zstd nixpkgs.dotenvx nixpkgs.nixos-rebuild

# Enable flakes
RUN mkdir -p ~/.config/nix
RUN echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

# Set working directory
WORKDIR /build

# We'll mount the files at runtime, so no COPY needed here
