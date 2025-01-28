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
}
