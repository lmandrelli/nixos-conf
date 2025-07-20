# Configuration système NixOS
{ config, lib, pkgs, inputs, ... }:

{
  # Importation de la configuration matérielle
  imports = [
    ./hardware-configuration.nix
  ];

  nixpkgs.config.allowUnfree = true;

  # === CONFIGURATION BOOTLOADER ===
  # GRUB2 avec support UEFI (adapté pour la plupart des installations modernes)
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # === CONFIGURATION RÉSEAU ===
  networking = {
    hostName = "nixos-SUPERNOVA"; # Changez selon vos préférences
    networkmanager.enable = true; # Interface graphique pour la gestion réseau
    # Pare-feu désactivé pour simplifier (réactivez selon vos besoins)
    firewall.enable = false;
  };

  # === CONFIGURATION RÉGIONALE ET LINGUISTIQUE ===
  # Fuseau horaire français
  time.timeZone = "Europe/Paris";
  
  # Configuration de la langue française
  i18n = {
    defaultLocale = "fr_FR.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "fr_FR.UTF-8";
      LC_IDENTIFICATION = "fr_FR.UTF-8";
      LC_MEASUREMENT = "fr_FR.UTF-8";
      LC_MONETARY = "fr_FR.UTF-8";
      LC_NAME = "fr_FR.UTF-8";
      LC_NUMERIC = "fr_FR.UTF-8";
      LC_PAPER = "fr_FR.UTF-8";
      LC_TELEPHONE = "fr_FR.UTF-8";
      LC_TIME = "fr_FR.UTF-8";
    };
  };

  # === CONFIGURATION CLAVIER ===
  # Clavier français AZERTY pour la console
  console.keyMap = "fr";

  # === CONFIGURATION GRAPHIQUE ===
  # Activation de l'environnement graphique avec support Wayland
  services.xserver = {
    enable = true;
    # Clavier français pour X11/Wayland
    xkb = {
      layout = "fr";
      variant = "";
    };
  };

  # KDE Plasma avec Wayland
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  
  # Support Wayland pour les applications
  services.displayManager.defaultSession = "plasma";
  
  # === CONFIGURATION AUDIO ===
  # PipeWire pour l'audio moderne avec support Wayland
  # CORRECTION: Utilisation de services.pulseaudio au lieu de hardware.pulseaudio
  services.pulseaudio.enable = false;
  security.rtkit.enable = true; # Nécessaire pour PipeWire
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # === CONFIGURATION GRAPHIQUE NVIDIA ===
  # Support NVIDIA avec drivers open-kernel OBLIGATOIRES pour RTX 5070
  services.xserver.videoDrivers = [ "nvidia" ];
  
  hardware.nvidia = {
    # Utilisation du driver open-kernel (nouveau driver open-source NVIDIA)
    open = true;
    
    # Activation du support Wayland pour NVIDIA
    modesetting.enable = true;
    
    # Support de la gestion d'énergie
    powerManagement.enable = true;
    
    # Utilisation du driver stable le plus récent
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Support OpenGL/Vulkan nécessaire pour les jeux et applications graphiques
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Support 32-bit pour Steam/Proton
  };

  # === CONFIGURATION PROCESSEUR INTEL ===
  # Microcode Intel pour les mises à jour de sécurité
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # === CONFIGURATION UTILISATEUR ===
  # Votre utilisateur principal
  users.users.lmandrelli = {
    isNormalUser = true;
    description = "lmandrelli";
    extraGroups = [ 
      "networkmanager" # Gestion réseau
      "wheel"         # Privilèges sudo
      "audio"         # Accès audio
      "video"         # Accès vidéo/caméra
      "input"         # Périphériques d'entrée
      "storage"       # Stockage
    ];
    shell = pkgs.zsh; # Shell par défaut
  };

  # === CONFIGURATION NIX ===
  # Activation des fonctionnalités expérimentales requises
  nix = {
    settings = {
      experimental-features = [
        "nix-command"  # Nouvelles commandes nix
        "flakes"       # Système de flakes pour la reproductibilité
      ];
      auto-optimise-store = true; # Optimisation automatique du store
    };
    
    # Nettoyage automatique des générations anciennes
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # === CONFIGURATION STEAM ET GAMING ===
  # Steam avec support Proton pour les jeux Windows
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true; # Session dédiée gaming
  };
  
  # Support des jeux 32-bit et des drivers
  programs.gamemode.enable = true; # Optimisations gaming
  
  # === SERVICES SYSTÈME ===
  # Bluetooth pour les périphériques sans fil
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  
  # Support des imprimantes
  services.printing.enable = true;
  
  # SSH pour l'accès distant
  services.openssh.enable = true;
  
  # === CONFIGURATION HYPRLAND ===
  # Gestionnaire de fenêtres Wayland moderne
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    xwayland.enable = true;
  };

  # Variables d'environnement pour Hyprland
  environment.sessionVariables = {
    # Support Wayland pour les applications
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1"; # Correctif pour certaines cartes graphiques
  };

  # === PACKAGES SYSTÈME ===
  # Packages disponibles pour tous les utilisateurs
  environment.systemPackages = with pkgs; [
    # Outils système essentiels
    wget curl git vim nano
    htop tree file
    
    # Support pour les formats d'archive
    unzip zip p7zip
    
    # Outils de développement de base
    gcc gnumake cmake
    
    # Outils Wayland
    wl-clipboard
    xdg-utils
    
    # Outils pour Hyprland
    waybar          # Barre de status
    wofi            # Lanceur d'applications
    swww            # Gestion des fonds d'écran
    grim slurp      # Captures d'écran
    wlogout         # Menu de déconnexion
    
    # Gestionnaire de fichiers
    kdePackages.dolphin
    
    # Navigateur de secours
    firefox
  ];

  # === SERVICES SPÉCIALISÉS ===
  # Polkit pour l'authentification graphique
  security.polkit.enable = true;
  
  # Portal pour les applications Flatpak/Snap
  # CORRECTION: Suppression de xdg-desktop-portal-hyprland pour éviter le conflit
  # Home Manager s'occupera de cette configuration
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      # xdg-desktop-portal-hyprland supprimé pour éviter le conflit
    ];
  };

  # === CONFIGURATION SHELLS ===
  # Zsh comme shell par défaut
  programs.zsh.enable = true;

  # === VERSION SYSTÈME ===
  # Version de NixOS (ne pas modifier)
  system.stateVersion = "25.05"; # Changez selon votre version d'installation

  # === CONFIGURATION SUDO ===
  security.sudo.enable = true;
}
