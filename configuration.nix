{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Kernel Parameters
  boot.kernelParams = [
    "amdgpu.sg_display=0"
    "amdgpu.aspm=0"
  ];

  # SSD
  services.fstrim = {
    enable = true;
    interval = "weekly";
  };

  # zram
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
  };

  # Hostname
  networking.hostName = "mercury";

  # Enable networking
  networking.networkmanager = {
    enable = true;
    plugins = with pkgs; [
      networkmanager-openvpn
    ];
  };

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Set your time zone.
  time.timeZone = "Asia/Tokyo";

  i18n.defaultLocale = "ru_RU.UTF-8";
  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "ja_JP.UTF-8/UTF-8"
    "ru_RU.UTF-8/UTF-8"
  ];

  console = {
    keyMap = "en";
  };

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };

  # Unfree
  nixpkgs.config.allowUnfree = true;

  # Fonts
  fonts = {
    packages = with pkgs; [
      noto-fonts-cjk-serif
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      nerdfetch
    ];
    fontconfig = {
      useEmbeddedBitmaps = true;
    };
  };

  # System packages
  environment.systemPackages = with pkgs; [
    git
    ffmpeg-full
    kdePackages.kdenlive
    audacity
    moonlight-qt
    btop
    songrec
    fastfetch
    telegram-desktop
    libreoffice-qt6-fresh
    obs-studio
    haruna
    vesktop
    easyeffects
    prismlauncher
    heroic
    byedpi
  ];

  # Services
  systemd.services.systemd-timesyncd.enable = false;
  systemd.services.ModemManager.enable = false;

  # Module plasma
  # SDDM and Plasma6
  services = {
    xserver = {
      enable = false;
      excludePackages = [ pkgs.xterm ];
    };
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      enableHidpi = true;
      autoNumlock = true;
    };
    desktopManager.plasma6 = {
      enable = true;
    };
  };
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-browser-integration
    oxygen
  ];

  # KDE Connect
  programs.kdeconnect.enable = true;

  # Module graphics
  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Module other/other
  # Exclude manual HTML
  documentation.nixos.enable = false;

  # Enable CUPS to print documents.
  services.printing.enable = false;

  # Module sound
  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.extraConfig."11-bluetooth-policy" = {
      "wireplumber.settings" = {
        "bluetooth.autoswitch-to-headset-profile" = false;
      };
    };
  };

  # Module user/qqqpppwww
  # User
  users.users.qqqpppwww = {
    isNormalUser = true;
    description = "qqqpppwww";
    extraGroups = [ "networkmanager" "wheel" "gamemode" "audio" ];
    packages = with pkgs; [];
  };

  # Module shell
  # zsh and aliases
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ll = "ls -l";
    };
    histSize = 2000;
  };
  # disable message
  system.userActivationScripts.zshrc = "touch .zshrc";
  # set as default shell
  users.defaultUserShell = pkgs.zsh;

  # Module apps/steam
  # Gaming
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = false;
      dedicatedServer.openFirewall = false;
      localNetworkGameTransfers.openFirewall = false;
      gamescopeSession.enable = true;
      package = pkgs.steam.override {
        extraPkgs =
        pkgs: with pkgs; [
          kdePackages.breeze
        ];
      };
    };
  };
  programs.gamemode.enable = true;

  # Module apps/firefox
  # Install firefox
  programs.firefox = {
    enable = true;
    languagePacks = [ "ru" ];
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableFeedbackCommands = true;
    };
    preferences = {
      "browser.uidensity" = 1;
      "widget.use-xdg-desktop-portal.file-picker" = 1;
      "extensions.pocket.api" =  "";
      "extensions.pocket.enabled" = false;
      "extensions.pocket.site" = "";
      "extensions.pocket.oAuthConsumerKey" = "";
      "datareporting.policy.dataSubmissionEnabled" = false;
      "datareporting.policy.firstRunURL" = "";
      "browser.tabs.crashReporting.sendReport" = false;
      "browser.tabs.crashReporting.email" = false;
      "browser.tabs.crashReporting.emailMe" = false;
      "network.allow-experiments" = false;
      "dom.ipc.plugins.reportCrashURL" = false;
      "dom.ipc.plugins.flash.subprocess.crashreporter.enabled" = false;
      "dom.security.https_only_mode" = true;
      "ui.key.menuAccessKeyFocuses" = false;
      "browser.contentblocking.category" = "strict";
      "privacy.globalprivacycontrol.enabled" = true;
      "browser.send_pings" = false;
      "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
      "media.peerconnection.enabled" = false;
    };
  };

  # Don't touch !!!
  system.stateVersion = "25.05";
}
