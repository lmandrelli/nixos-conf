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
  
  # Paramètres kernel pour NVIDIA Wayland
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
  ];

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
  # Activation de l'environnement graphique avec support Wayland et XWayland
  services.xserver = {
    enable = true;
    # Clavier français pour X11/Wayland
    xkb = {
      layout = "fr";
      variant = "";
    };
  };
  
  # XWayland support pour KDE Plasma
  programs.xwayland.enable = true;

  # GDM Display Manager pour l'écran de connexion
  services.displayManager.gdm.enable = true;
  services.displayManager.gdm.wayland = true;
  
  # KDE Plasma 6 avec Wayland
  services.desktopManager.plasma6.enable = true;
  
  # Session par défaut : KDE Plasma Wayland
  services.displayManager.defaultSession = "plasma";
  
  # === CONFIGURATION NUM LOCK ===
  # Activation du Num Lock pour GDM (écran de connexion)
  programs.dconf.profiles.gdm.databases = [{
    settings."org/gnome/desktop/peripherals/keyboard" = {
      numlock-state = true;
      remember-numlock-state = true;
    };
  }];
  
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
    
    # Support de la gestion d'énergie (désactivé pour éviter les problèmes Wayland)
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    
    # Menu des paramètres NVIDIA
    nvidiaSettings = true;
    
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
      "docker"        # Accès Docker
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
      
      # Configuration des caches binaires (plus sécurisé en premier)
      substituters = [
        "https://cache.nixos.org/"        # Cache officiel NixOS (plus sécurisé)
        "https://nix-community.cachix.org" # Cache communautaire Nix
      ];
      
      # Clés publiques de confiance pour vérification des signatures
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="           # Cache officiel NixOS
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" # Cache communautaire
      ];
      
      # Sécurité: Vérification obligatoire des signatures
      require-sigs = true;
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
  
  # === CONFIGURATION DOCKER ===
  # Docker pour la conteneurisation
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    
    # Configuration recommandée pour les performances
    storageDriver = "overlay2";
    
    # Support rootless Docker (optionnel, plus sécurisé)
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };
  
  # === CONFIGURATION HYPRLAND ===
  # Gestionnaire de fenêtres Wayland moderne
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    xwayland.enable = true;
  };

  # Variables d'environnement essentielles pour KDE Plasma Wayland
  environment.sessionVariables = {
    # Support Wayland pour les applications Chromium/Electron
    NIXOS_OZONE_WL = "1";
  };

  # === PACKAGES SYSTÈME ===
  # Packages disponibles pour tous les utilisateurs
  environment.systemPackages = with pkgs; [
    # Outils système essentiels
    wget curl git vim nano
    htop tree file
    
    # Cache binaire
    cachix
    
    # Support pour les formats d'archive
    unzip zip p7zip
    
    # Outils de développement de base
    gcc gnumake cmake
    
    # Outils Wayland et XWayland
    wl-clipboard
    xdg-utils
    xwayland
    
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
  
  # === CONFIGURATION SSH ASKPASS ===
  # Utilise l'askpass KDE pour une meilleure intégration
  programs.ssh.askPassword = lib.mkForce "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";
}
