{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "amdgpu.sg_display=0"
      "amdgpu.aspm=0"
    ];
  };

  # zram
  zramSwap = {
    enable = true;
    algorithm = "lz4";
    memoryPercent = 25;
  };

  # Enable networking, hostname, nftables
  networking = {
    hostName = "mercury";
    nftables.enable = true;
    networkmanager = {
      enable = true;
      plugins = with pkgs; [
        networkmanager-openvpn
      ];
    };
  };

  # Set your time zone.
  time.timeZone = "Asia/Tokyo";

  # Keymap for console
  console = {
    keyMap = "en";
  };

  i18n = {
    inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        addons = with pkgs; [
          fcitx5-mozc
          fcitx5-gtk
        ];
        ignoreUserConfig = true;
        settings = {
          inputMethod = {
            "Groups/0" = {
              Name = "Default";
              "Default Layout" = "us";
              DefaultIM = "keyboard-us";
            };
            "Groups/0/Items/0".Name = "keyboard-us";
            "Groups/0/Items/1".Name = "keyboard-ru";
            "Groups/0/Items/2".Name = "mozc";
          };
        };
      };
    };
    extraLocaleSettings = {
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
    defaultLocale = "ru_RU.UTF-8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "ja_JP.UTF-8/UTF-8"
      "ru_RU.UTF-8/UTF-8"
    ];
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
  environment = {
    systemPackages = with pkgs; [
      git
      yt-dlp
      freetube
      gimp
      spotify
      qbittorrent
      mangohud
      goverlay
      obsidian
      ffmpeg-full
      kdePackages.kdenlive
      audacity
      moonlight-qt
      btop
      songrec
      fastfetch
      telegram-desktop
      libreoffice-qt-fresh
      obs-studio
      haruna
      vesktop
      easyeffects
      prismlauncher
      heroic
      byedpi
    ];
    plasma6.excludePackages = with pkgs.kdePackages; [
      plasma-browser-integration
      oxygen
    ];
  };

  # Waydroid & virtualisation
  virtualisation = {
    waydroid.enable = true;
  };

  # Programs
  programs = {
    # kdeconnect
    kdeconnect.enable = true;
    # Android
    adb.enable = true;
    # Steam
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
    # Gamemode
    gamemode = {
      enable = true;
    };
    # zsh
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      shellAliases = {
        ll = "ls -l";
      };
      histSize = 2000;
    };
    # Browser
    firefox = {
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
  };

  # Module hardware
  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  # Exclude manual HTML
  documentation.nixos.enable = false;

  # CUPS, Plasma & other services
  services = {
    # xorg, wayland, ssdm, plasma
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
    desktopManager.plasma6.enable = true;
    # CUPS
    printing = {
      enable = false;
    };
    # SSD
    fstrim = {
      enable = true;
      interval = "weekly";
    };
    # Sound
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      wireplumber.extraConfig."11-bluetooth-policy" = {
        "wireplumber.settings" = {
          "bluetooth.autoswitch-to-headset-profile" = false;
        };
      };
    };
    # CPU Scheduler
    scx = {
      enable = true;
      scheduler = "scx_lavd";
      extraArgs = [ "--performance" ];
    };
  };
  systemd = {
    services = {
      systemd-timesyncd.enable = false;
      ModemManager.enable = false;
    };
  };

  # Module security
  security = {
    rtkit.enable = true;
  };

  # Module User
  users = {
    defaultUserShell = pkgs.zsh;
    users.qqqpppwww = {
      isNormalUser = true;
      description = "qqqpppwww";
      extraGroups = [ "networkmanager" "wheel" "gamemode" "audio" ];
      packages = with pkgs; [];
    };
  };

  # disable message in zsh
  system.userActivationScripts.zshrc = "touch .zshrc";

  # Don't touch !!!
  system.stateVersion = "25.05";
}
