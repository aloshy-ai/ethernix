{ pkgs, ... }:

{
  # Import hardware configuration
  imports = [
    ./hardware-configuration.nix
  ];

  # Nix package manager configuration
  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
      experimental-features = nix-command flakes
    '';
    settings = {
      trusted-users = [ "aloshy" "runner" ];
    };
  };

  # Boot configuration for ARM64
  boot = {
    loader = {
      grub.enable = false;  # Disable GRUB for ARM
      generic-extlinux-compatible.enable = true;  # Use extlinux for ARM
    };
  };

  # Network configuration
  networking = {
    hostName = "ethernix";
    # Static IP configuration
    interfaces = {
      end0 = {
        ipv4 = {
          addresses = [{
            address = "192.168.8.69";
            prefixLength = 24;
          }];
        };
      };
    };
    defaultGateway = {
      address = "192.168.8.1";
      interface = "end0";
    };
    nameservers = [ "192.168.8.1" ];
  };

  # System services configuration
  services = {
    # SSH server configuration
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        X11Forwarding = true;
      };
    };
    # Tailscale VPN configuration
    tailscale = {
      enable = true;
      authKeyFile = "/etc/tailscale/authkey";
      extraUpFlags = [
        "--ssh"
        "--advertise-exit-node"
      ];
    };
  };

  users = {
    users = {
      aloshy = {
        isNormalUser = true;
        extraGroups = [ "wheel" "docker" "networkmanager" "video" "audio" "caddy" "libvirtd" "disk" "storage" "dialout" "wireshark" "plugdev" ];
        openssh = {
          authorizedKeys = {
            keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINzsLYdG0gkky7NCydRoqc0EMYEb61V+xsFKYJpH+ivV aloshy@ETHERFORGE.local"
            ];
          };
        };
        hashedPassword = "$6$OF89tQYOvaEHKCfx$KYSdQu/GHroUMovkUKUqbvUpEM51MurUpLob6E9YiEMWxvABDsrfACQxej02f9xuV5.HnNtMmpEoLDeAqCZfB1";
      };
      runner = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
      };
    };
  };

  environment = {
    systemPackages = with pkgs; [ ];
    variables = {
      SHELL = "zsh";
      EDITOR = "nano";
    };
  };

  home-manager = {
    users = {
      aloshy = { pkgs, ... }: {
        home = {
          packages = with pkgs; [ devbox ];
          stateVersion = "25.05";
        };
        programs = {
          bash = {
            enable = true;
          };
          zsh = {
            enable = true;
            initExtra = ''
              eval "$(devbox global shellenv)"
            '';
          };
          git = {
            enable = true;
            userName = "aloshy.🅰🅸";
            userEmail = "noreply@aloshy.ai";
            lfs = {
              enable = true;
            };
          };
          gh = {
            enable = true;
          };
          direnv = {
            enable = true;
            nix-direnv = {
              enable = true;
            };
            enableBashIntegration = true;
          };
        };
      };
    };
  };

  virtualisation = {
    docker = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };
  };

  system = {
    stateVersion = "25.05";
  };
}