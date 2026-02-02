{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # Bootloader
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

  # Zram
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

  # Time zone
  time.timeZone = "Asia/Tokyo";

  # Keymap for console
  console = {
    keyMap = "en";
  };

  # Input method, fcitx5
  i18n = {
    inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        addons = with pkgs; [
          fcitx5-mozc
          fcitx5-gtk
        ];
        waylandFrontend = true;
        ignoreUserConfig = true;
        settings = {
          globalOptions = {
            "Hotkey/TriggerKeys" = {
              "0" = "Control+space";
            };
          };
          inputMethod = {
            "Groups/0" = {
              Name = "Default";
              "Default Layout" = "us";
              DefaultIM = "keyboard-us";
            };
            "Groups/0/Items/0".Name = "keyboard-us";
            "Groups/0/Items/1".Name = "keyboard-ru";
            "Groups/0/Items/2".Name = "mozc";
            GroupOrder."0" = "Default";
          };
        };
      };
    };
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "ja_JP.UTF-8/UTF-8"
      "ru_RU.UTF-8/UTF-8"
    ];
  };

  # Allow unfree packages
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
      wget
      yt-dlp
      pkgs.anki
      gimp
      spotify
      qbittorrent
      krita
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
    # xorg, wayland, sddm, plasma
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
    users = {
      qqqpppwww = {
        isNormalUser = true;
        description = "qqqpppwww";
        extraGroups = [ "networkmanager" "wheel" "gamemode" "audio" ];
        packages = with pkgs; [];
      };
    };
  };

  # Disable message in zsh
  system.userActivationScripts.zshrc = "touch .zshrc";

  # Don't touch !!!
  system.stateVersion = "25.11";
}

