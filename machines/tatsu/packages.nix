{ pkgs, ... }:
{
  documentation.dev.enable = true;
  users.users.hannes.packages = with pkgs; [
    # display manager tools
    swaylock
    swaybg
    waybar
    catppuccin-cursors.mochaLight
    networkmanagerapplet
    brightnessctl
    xwayland-satellite
    xdg-desktop-portal
    wl-clipboard # clipboard management
    wtype # typing
    wlsunset # redshift

    # launcher
    rofi

    # daemons
    batsignal
    fnott

    # desktop programs
    alacritty
    firefox
    spotify
    signal-desktop
    # obsidian
    # logseq
    wireshark
    nautilus
    libqalculate
    loupe

    # cli
    # yazi
    zoxide
    bat
    tldr
    # taskwarrior3
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

    vscode.fhs
    zed-editor
    antigravity
    pika-backup

    # dev
    git
    delta # diffing tool
    jujutsu
    gcc
    gnumake
    wakatime-cli
    github-desktop

    # nix language servers
    nil
    nixd

    rustup
    podman-compose

    fishPlugins.fish-you-should-use
  ];

  fonts.packages = with pkgs; [
    font-awesome
    nerd-fonts.fantasque-sans-mono
    atkinson-hyperlegible-mono
    xits-math
  ];
}
