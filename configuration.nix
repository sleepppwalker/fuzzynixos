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
  ];

  # Microcode
  hardware.cpu.intel.updateMicrocode = true;

  # SSD
  services.fstrim = {
    enable = true;
    interval = "weekly";
  };

  # Kernel sysctl
  boot.kernel.sysctl = {
    "vm.max_map_count" = 2147483642;
    "kernel.perf_cpu_time_max_percent" = 0;
    "kernel.sched_cfs_bandwidth_slice_us" = 3000;
    "vm.swappiness" = 5;
    "vm.vfs_cache_pressure" = 50;
    "vm.dirty_background_ratio" = 20;
    "vm.dirty_ratio" = 50;
    "kernel.sched_latency_ns" = 4000000;
    "kernel.sched_min_granularity_ns" = 500000;
    "kernel.sched_wakeup_granularity_ns" = 50000;
    "kernel.sched_migration_cost_ns" = 250000;
    "kernel.sched_nr_migrate" = 128;
    "kernel.perf_event_max_sample_rate" = 350000;
  };

  # ClamAV
  services.clamav = {
    daemon.enable = false;
    updater.enable = false;
  };

  # zram
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 30;
  };

  # Hostname
  networking.hostName = "uwu";

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Chita";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

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
        layout = "us";
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
    libinput = {
      touchpad.disableWhileTyping = true;
    };
  };
  services.desktopManager.plasma6.enable = true;
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-browser-integration
    oxygen
  ];

  # KDE Connect
  programs.kdeconnect.enable = true;

  # Exclude manual HTML
  documentation.nixos.enable = false;

  # Environment for performance
  environment.variables = {
    KWIN_DRM_DEVICES = "/dev/dri/card0:/dev/dri/card1";
    #KWIN_DRM_DELAY_VRR_CURSOR_UPDATES = "1";
    #KWIN_FORCE_SW_CURSOR = "1";
    #GALLIUM_DRIVER = "zink";
    #KWIN_DRM_USE_MODIFIERS = "1";
    #KWIN_DRM_FORCE_MGPU_GL_FINISH = "1";
    #KWIN_DRM_DISABLE_TRIPLE_BUFFERING = "0";
  };

  # Unfree
  nixpkgs.config.allowUnfree = true;

  # Mesa and hardware acceleration video playback
  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  };
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-media-sdk
    ];
  };
  environment.sessionVariables = {
     LIBVA_DRIVER_NAME = "iHD";
     #VK_DRIVER_FILES = "/run/opengl-driver/share/vulkan/icd.d/nouveau_icd.x86_64.json";
     #SDL_VIDEODRIVER = "'wayland,x11,windows'";
  };

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
      "pulse.min.req" = "2048/48000";
      "pulse.default.req" = "2048/48000";
      "pulse.max.req" = "2048/48000";
      "pulse.min.quantum" = "2048/48000";
      "pulse.max.quantum" = "2048/48000";
    };
    "stream.properties" = {
      "node.latency" = "2048/48000";
      "resample.quality" = 1;
    };
  };

  # User
  users.users.kowasu = {
    isNormalUser = true;
    description = "kowasu";
    extraGroups = [ "networkmanager" "wheel" "gamemode" ];
    packages = with pkgs; [
      htop
      neofetch
      telegram-desktop
    ];
  };

  # Aliases
  programs = {
    bash = {
      shellAliases = {
        eturbo = "echo 0 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo";
        dturbo = "echo 1 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo";
        # cursorfix = "ln -s /run/current-system/sw/share/icons .local/share/icons";
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
    easyeffects
    clamav
  ];

  # Don't touch
  system.stateVersion = "24.11"; # Did you read the comment?
}
