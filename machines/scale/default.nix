{ pkgs, lib, ...}:

{
  wsl.enable = true;
  wsl.defaultUser = "hannes";
  wsl.wslConf.network.generateResolvConf = false;

  networking.nameservers = [ "192.168.0.1" ];

  nixpkgs.config.allowUnfree = true;

  virtualisation = {
    podman.enable = true;
    docker = {
      enable = true;
      daemon.settings = {
        bip = "172.30.0.1/24";
        default-address-pools = [
          {
            base = "172.31.0.0/16";
            size = 24;
          }
        ];
      };
    };
  };


  programs = {
    nix-ld.enable = true;
    nix-index-database.comma.enable = true;
  };


  users.users.hannes.packages = with pkgs; [
    zoxide
    bat
    tldr
    atuin
    man-pages
    man-pages-posix
    tree
    timer
    dig
    bacon
    lazysql
    gdb
    htop
    nh

    zed-editor

    git
    delta # diffing tool
    jujutsu
    gcc
    gnumake
    wakatime-cli

    rustup
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "25.11";
}
