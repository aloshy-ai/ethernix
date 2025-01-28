# configuration.nix

{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;
  
  # networking config. important for ssh!
  networking = {
    hostName = "ethernix";
    interfaces.end0 = {
      ipv4.addresses = [{
        address = "192.168.8.69";
        prefixLength = 24;
      }];
    };
    defaultGateway = {
      address = "192.168.8.1"; # or whichever IP your router is
      interface = "end0";
    };
    nameservers = [
      "192.168.8.1" # or whichever DNS server you want to use
    ];
  };
  
  # the user account on the machine
  users.users.aloshy = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable 'sudo' for the user.
    hashedPassword = "$6$OF89tQYOvaEHKCfx$KYSdQu/GHroUMovkUKUqbvUpEM51MurUpLob6E9YiEMWxvABDsrfACQxej02f9xuV5.HnNtMmpEoLDeAqCZfB1"; # generate with `mkpasswd`
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # I use neovim as my text editor, replace with whatever you like
  environment.systemPackages = with pkgs; [
    neovim
    wget
  ];

  # allows the use of flakes
  nix.package = pkgs.nixVersions.stable;
  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
    experimental-features = nix-command flakes
  '';

  # this allows you to run `nixos-rebuild --target-host aloshy@this-machine` from
  # a different host. not used in this tutorial, but handy later.
  nix.settings.trusted-users = [ "aloshy" ];

  # ergonomics, just in case I need to ssh into
  programs.zsh.enable = true;
  environment.variables = {
    SHELL = "zsh";
    EDITOR = "nano";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of your first install.
  system.stateVersion = "25.05";
}
# configuration.nix

{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    <home-manager/nixos>
  ];

  # Boot Configuration
  boot = {
    loader = {
      grub = {
        enable = false;
      };
      generic-extlinux-compatible = {
        enable = true;
      };
    };
  };
  
  # System Configuration
  system = {
    stateVersion = "25.05";
  };

  # Nix Package Manager Configuration
  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
      experimental-features = nix-command flakes
    '';
    settings = {
      trusted-users = [
        "aloshy"
      ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 1d";
    };
  };

  # Network Configuration
  networking = {
    hostName = "ethernix";
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
    nameservers = [
      "192.168.8.1"
    ];
  };

  # User Configuration
  users = {
    users = {
      aloshy = {
        isNormalUser = true;
        extraGroups = [ 
          "wheel" 
          "docker" 
          "networkmanager" 
          "video" 
        ];
        hashedPassword = "$6$OF89tQYOvaEHKCfx$KYSdQu/GHroUMovkUKUqbvUpEM51MurUpLob6E9YiEMWxvABDsrfACQxej02f9xuV5.HnNtMmpEoLDeAqCZfB1";
        shell = pkgs.zsh;
        openssh = {
          authorizedKeys = {
            keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINzsLYdG0gkky7NCydRoqc0EMYEb61V+xsFKYJpH+ivV aloshy@ETHERFORGE.local"
            ];
          };
        };
      };
    };
  };

  # Environment Configuration
  environment = {
    systemPackages = with pkgs; [
      tailscale
    ];
    variables = {
      SHELL = "zsh";
      EDITOR = "nano";
    };
  };

  # Program Configuration
  programs = {
    zsh = {
      enable = true;
    };
  };

  # Home Manager Configuration
  home-manager.users.aloshy = { pkgs, ... }: {
    home = {
      packages = with pkgs; [ 
        devbox
      ];
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

  # Virtualization Configuration
  virtualisation = {
    docker = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };
  };

  # Services Configuration
  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        X11Forwarding = true;
      };
    };
    tailscale = {
      enable = true;
      authKeyFile = "/etc/tailscale/authkey";
      extraUpFlags = [
        "--ssh"
        "--advertise-exit-node"
      ];
    };
  };
}