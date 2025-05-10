{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel Parameters
  boot.kernelParams = [
    "i915.enable_psr=0"
    "i915.enable_fbc=1"
    "i915.enable_dc=1"
  ];

  boot.extraModprobeConfig = ''
    options nvidia NVreg_UsePageAttributeTable=1
    options nvidia NVreg_EnableGpuFirmware=0
  '';


  # CPU-tuning
  hardware.cpu.intel.updateMicrocode = true;
  services.thermald.enable = true;

  # SSD
  services.fstrim = {
    enable = true;
    interval = "weekly";
  };

  # Kernel sysctl
  boot.kernel.sysctl = {
    "vm.max_map_count" = 2147483642;
    "kernel.perf_cpu_time_max_percent" = 0;
  };

  # ClamAV
  services.clamav = {
    daemon.enable = true;
    updater.enable = false;
  };

  # zram
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
  };

  # Hostname
  networking.hostName = "mercury";

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Chita";

  # Select internationalisation properties
  /* i18n.inputMethod = {
   type = "fcitx5";
   enable = true;
   fcitx5.addons = with pkgs; [
     fcitx5-mozc
     fcitx5-gtk
   ];
  }; */

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
      noto-fonts-emoji
      nerdfetch
    ];
    fontconfig = {
      useEmbeddedBitmaps = true;
    };
  };

  # System packages
  environment.systemPackages = with pkgs; [

  ];

  # Services
  systemd.services.systemd-timesyncd.enable = false;
  systemd.services.ModemManager.enable = false;

  # Module plasma
  # SDDM and Plasma6
  services = {
    xserver = {
      enable = false;
      xkb = {
        layout = "us,ru";
        variant = "";
      };
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
    libinput = {
      touchpad.disableWhileTyping = true;
    };
  };
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-browser-integration
    oxygen
  ];

  # xdg-portals
  xdg.portal = {
   enable = true;
  };

  # KDE Connect
  programs.kdeconnect.enable = true;

  # Module environment
  # Environment for performance
  environment.variables = {
    KWIN_DRM_DISABLE_TRIPLE_BUFFERING = "0";
    __GL_YIELD = "USLEEP";
  };

  # Module graphics
  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-sdk
      intel-media-driver
      intel-compute-runtime-legacy1
      intel-vaapi-driver
      libvdpau-va-gl
    ];
  };

  # VAAPI
  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  hardware.nvidia.prime = {
    reverseSync.enable = true;
    allowExternalGpu = false;
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
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
    extraConfig = {
      pipewire-pulse."92-low-latency" = {
        "context.properties" = [
          {
            name = "libpipewire-module-protocol-pulse";
            args = { };
          }
        ];
        "pulse.properties" = {
          "pulse.min.req" = "1024/48000";
          "pulse.default.req" = "1024/48000";
          "pulse.max.req" = "1024/48000";
          "pulse.min.quantum" = "1024/48000";
          "pulse.max.quantum" = "1024/48000";
        };
        "stream.properties" = {
          "node.latency" = "1024/48000";
          "resample.quality" = 4;
        };
      };
      pipewire."92-low-latency" = {
        "context.properties" = {
          "default.clock.rate" = "48000";
          "default.clock.quantum" = "1024";
          "default.clock.min-quantum" = "1024";
          "default.clock.max-quantum" = "1024";
        };
        "context.modules" = [
          {
            name = "libpipewire-module-rt";
            args = {
              "nice.level" = "-20";
              "rt.prio" = "99";
              "rt.time.soft" = "99999";
              "rt.time.hard" = "99999";
            };
          }
        ];
      };
    };
  };
  security.pam.loginLimits = [
    {
      domain = "@audio";
      item = "memlock";
      type = "-";
      value = "unlimited";
    }
    {
      domain = "@audio";
      item = "rtprio";
      type = "-";
      value = "99";
    }
    {
      domain = "@audio";
      item = "nofile";
      type = "soft";
      value = "99999";
    }
    {
      domain = "@audio";
      item = "nofile";
      type = "hard";
      value = "99999";
    }
  ];
  services.udev = {
    extraRules = ''
      KERNEL=="rtc0", GROUP="audio"
      KERNEL=="hpet", GROUP="audio"
    '';
  };

  # Module user/kowasu
  # User
  users.users.kowasu = {
    isNormalUser = true;
    description = "kowasu";
    extraGroups = [ "networkmanager" "wheel" "gamemode" "audio" "libvirtd" ];
    packages = with pkgs; [
      btop
      anki-bin
      obsidian
      songrec
      neofetch
      telegram-desktop
      libreoffice-qt6-fresh
      obs-studio
      mpv
      vesktop
      easyeffects
      clamtk
      prismlauncher
      heroic
    ];
  };

  # Virtualization moduke
  # Enable libvirt and qemu
  # чому отключено runAsRoot? - копируем iso в tmp)))
  virtualisation = {
    libvirtd = {
      enable = true;
      onBoot = "ignore";
      onShutdown = "shutdown";
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = false;
        swtpm.enable = true;
        ovmf = {
          enable = true;
          packages = [(pkgs.OVMF.override {
            secureBoot = true;
            tpmSupport = true;
          }).fd];
        };
      };
    };
  };
  programs.virt-manager.enable = true;

  # Module shell
  # zsh and aliases
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ll = "ls -l";
      eturbo = "echo 0 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo";
      dturbo = "echo 1 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo";
    };
    histSize = 2000;
  };
  # disable message
  system.userActivationScripts.zshrc = "touch .zshrc";
  # set as default shell
  users.defaultUserShell = pkgs.zsh;

  # Module apps/steam
  # Gaming
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = false;
    dedicatedServer.openFirewall = false;
    localNetworkGameTransfers.openFirewall = false;
    package = pkgs.steam.override {
      extraPkgs =
      pkgs: with pkgs; [
        kdePackages.breeze
      ];
    };
  };
  programs.steam.gamescopeSession.enable = true;
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
      "network.trr.mode" = 3;
      "network.trr.uri" = "https://mozilla.cloudflare-dns.com/dns-query";
      "network.trr.bootstrapAddress" = "1.1.1.1";
      "ui.key.menuAccessKeyFocuses" = false;
      "browser.contentblocking.category" = "strict";
      "privacy.globalprivacycontrol.enabled" = true;
      "browser.send_pings" = false;
      "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
    };
  };

  # Don't touch !!!
  system.stateVersion = "25.05";
}
