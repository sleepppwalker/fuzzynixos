{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Kernel Parameters
  boot.kernelParams = [
    "nouveau.config=NvGspRm=1"
    "nouveau.runpm=0"
    "i915.enable_psr=0"
    "i915.enable_guc=2"
    "i915.enable_fbc=1"
    "i915.enable_dc=0"
    "fbdev=1"
  ];

  # Microcode
  hardware.cpu.intel.updateMicrocode = true;
  services.thermald.enable = true;

  # CPU
  #services.undervolt = {
  #  enable = true;
  #  coreOffset = -110;
  #};

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
    algorithm = "lz4";
    memoryPercent = 50;
  };

  # Hostname
  networking.hostName = "kowareru";

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Chita";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
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

  # Enable the WAYLAND and NVIDIA, plasma6 too blyat'
  services = {
    xserver = {
      enable = false;
      xkb = {
        layout = "us,ru";
        variant = "";
      };
      excludePackages = [ pkgs.xterm ];
      videoDrivers = [ "nouveau" ];
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

  # VAAPI
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-sdk
      intel-media-driver
      libvdpau-va-gl
    ];
  };
  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; };

  # KDE Connect
  programs.kdeconnect.enable = true;

  # Exclude manual HTML
  documentation.nixos.enable = false;

  # Environment for performance
  environment.variables = {
    KWIN_DRM_DISABLE_TRIPLE_BUFFERING = "1";
    KWIN_DRM_DELAY_VRR_CURSOR_UPDATES = "1";
    KWIN_FORCE_SW_CURSOR = "1";
    NOUVEAU_USE_ZINK = "1";
    GALLIUM_DRIVER = "zink";
    #KWIN_DRM_DEVICES = "/dev/dri/card0:/dev/dri/card1";
  };

  # Unfree
  nixpkgs.config.allowUnfree = true;

  # Enable CUPS to print documents.
  services.printing.enable = false;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Best sound
  services.pipewire.extraConfig.pipewire-pulse."92-low-latency" = {
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
      "resample.quality" = 1;
    };
  };

  # User
  users.users.kowasu = {
    isNormalUser = true;
    description = "kowasu";
    extraGroups = [ "networkmanager" "wheel" "gamemode" ];
    packages = with pkgs; [
      btop
      neofetch
      telegram-desktop
      libreoffice-qt6-fresh
      emacs
      obs-studio
      vlc
      mpv
      discord
      clamtk
      easyeffects
    ];
  };

  # Aliases
  programs = {
    bash = {
      shellAliases = {
        eturbo = "echo 0 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo";
        dturbo = "echo 1 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo";
      };
    };
  };

  # Gaming
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = false;
    dedicatedServer.openFirewall = false;
    localNetworkGameTransfers.openFirewall = false;
  };
  programs.steam.gamescopeSession.enable = true;
  programs.gamemode.enable = true;

  # Install firefox.
  programs.firefox.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    noto-fonts-cjk-sans
    liberation_ttf
  ];

  # System packages
  environment.systemPackages = with pkgs; [

  ];

  # Services
  systemd.services.systemd-timesyncd.enable = false;
  systemd.services.ModemManager.enable = false;

  # Don't touch
  system.stateVersion = "24.11";
}
