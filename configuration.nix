{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
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
  ];

  # CPU and Microcode
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
  
  # dconf
  programs.dconf = {
    enable = true;
  };

  # Enable the GNOME Desktop Environment. Turn off X11 and enable NOUVEAU.
  services = {
    xserver = {
      enable = false;
      xkb = {
        layout = "us,ru";
        variant = "";
      };
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      excludePackages = [ pkgs.xterm ];
      videoDrivers = [ "nouveau" ];
    };
    libinput = {
      touchpad.disableWhileTyping = true;
    };
  };
  environment.gnome.excludePackages = with pkgs; [
    orca
    evince
    geary
    gnome-disk-utility
    gnome-tour
    gnome-clocks
    gnome-user-docs
    baobab
    epiphany
    gnome-calendar
    gnome-characters
    gnome-contacts
    gnome-font-viewer
    gnome-logs
    gnome-maps
    gnome-music
    gnome-weather
    gnome-connections
    simple-scan
    snapshot
    totem
    yelp
    gnome-software
  ];
  
  # xdg-portals
  xdg.portal = {
   enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
    ];
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

  # Enable CUPS to print documents.
  services.printing.enable = false;
  
  # Exclude manual HTML
  documentation.nixos.enable = false;

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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kowasu = {
    isNormalUser = true;
    description = "kowasu";
    extraGroups = [ "networkmanager" "wheel" "gamemode" ];
    packages = with pkgs; [
      btop
      neofetch
      telegram-desktop
      libreoffice-fresh
      emacs-gtk
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

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
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
