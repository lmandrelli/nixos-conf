# Configuration Home Manager pour lmandrelli
{ config, pkgs, inputs, ... }:

{
  # Imports des modules
  imports = [
    # Aucun module externe pour le moment
  ];
  # === INFORMATIONS UTILISATEUR ===
  home = {
    username = "lmandrelli";
    homeDirectory = "/home/lmandrelli";
    stateVersion = "25.05"; # Version de home-manager (alignée sur NixOS)
  };

  # === PACKAGES UTILISATEUR ===
  # Applications et outils spécifiques à l'utilisateur
  home.packages = with pkgs; [
    # === COMPATIBILITÉ WAYLAND/X11 ===
    xwayland xorg.xhost
    # Bridge X11 vers Wayland pour KDE Plasma
    xdg-desktop-portal-wlr
    xdg-desktop-portal-gtk
    # Num Lock control
    numlockx
    # === POLICES ===
    jetbrains-mono nerd-fonts.jetbrains-mono nerd-fonts.meslo-lg

    # === DÉVELOPPEMENT ===
    # Rust et son écosystème
    rustc cargo rustfmt clippy
    
    # Node.js et outils JavaScript/TypeScript
    nodePackages.npm nodePackages.prettier
    bun # Runtime JavaScript moderne et rapide
    
    # Java Development Kit
    jdk # ou jdk21 selon vos besoins
    
    # Python avec support des environnements virtuels
    python3 python3Packages.virtualenv python3Packages.pip
    uv # Gestionnaire de paquets Python moderne
    
    # === ÉDITEURS ET IDE ===
    # Visual Studio Code - éditeur populaire avec extensions
    vscode # Version standard (pas FHS)
    
    # Zed - éditeur moderne écrit en Rust
    zed-editor

    opencode
    
    # === TERMINAUX ===
    # Warp - terminal moderne avec IA intégrée
    warp-terminal
    
    # Kitty - terminal rapide avec support GPU
    kitty
    
    # === APPLICATIONS DE COMMUNICATION ===
    # Discord pour la communication gaming/développement
    vesktop
    
    # === MULTIMÉDIA ===
    # Spotify pour la musique en streaming
    spotify
    
    
    # VLC - lecteur multimédia universel
    vlc
    
    # === BUREAUTIQUE ===
    # LibreOffice - suite bureautique complète
    libreoffice-qt # Version Qt pour une meilleure intégration KDE
    
    # Obsidian - prise de notes avec liens et graphiques
    obsidian
    
    # === NAVIGATEURS ===
    # Firefox comme navigateur principal (déjà installé système)
    # Chromium comme navigateur secondaire
    chromium
    
    # === OUTILS DE CRÉATION ===
    # Inkscape - création vectorielle
    inkscape
    
    # GIMP - édition d'images bitmap
    gimp
    
    # === SÉCURITÉ ===
    # Bitwarden - gestionnaire de mots de passe
    bitwarden-desktop
    
    # === OUTILS SYSTÈME ET DÉVELOPPEMENT ===
    # Outils pour direnv et nix
    nix-direnv
    
    # Outils Git avancés
    git-lfs gh # GitHub CLI
    
    # === OUTILS DOCKER ===
    # Docker et outils de conteneurisation
    docker-compose     # Orchestration multi-conteneurs
    lazydocker        # Interface TUI pour Docker
    dive              # Analyse des couches d'images Docker
    ctop              # Monitoring des conteneurs en temps réel
    
    # === HYPRLAND ECOSYSTEM ===
    waybar        # Barre de statut personnalisable
    wofi          # Lanceur d'applications style rofi
    swww          # Gestion des fonds d'écran animés
    grim slurp    # Outils de capture d'écran
    wlogout       # Menu de déconnexion élégant
    swaylock-effects # Écran de verrouillage avec effets
    swayidle      # Gestion de l'inactivité
    mako          # Système de notifications
    pavucontrol   # Contrôle audio graphique
    brightnessctl # Contrôle de la luminosité
    playerctl     # Contrôle des lecteurs multimédia
    cliphist      # Gestionnaire d'historique presse-papiers
    wtype         # Outil de saisie Wayland
    
    # Outils ML4W-inspired pour Hyprland
    hypridle      # Gestion de l'inactivité Hyprland
    hyprlock      # Écran de verrouillage Hyprland
    hyprpicker    # Sélecteur de couleurs
    hyprshot      # Screenshots optimisés Hyprland
    wl-clipboard-rs # Gestionnaire presse-papiers Rust
    
    # === APPIMAGE SUPPORT ===
    appimage-run  # Nécessaire pour exécuter les AppImages sur NixOS
  ];

  # === GESTION DES APPIMAGES ===


  # Création du fichier .desktop pour Cider AppImage
  home.file.".local/share/applications/cider.desktop" = {
    text = ''
      [Desktop Entry]
      Type=Application
      Name=Cider
      Comment=Client Apple Music alternatif
      Exec=${config.home.homeDirectory}/.local/bin/appimages/cider.AppImage
      Icon=${config.home.homeDirectory}/.local/share/icons/cider.svg
      Categories=AudioVideo;Audio;Player;
      StartupNotify=true
      StartupWMClass=cider
      MimeType=audio/mpeg;audio/flac;audio/ogg;audio/mp4;
      Keywords=music;audio;player;apple;streaming;
    '';
  };
  
  # S'assurer que le répertoire AppImages existe
  home.file.".local/bin/appimages/.keep".text = "";

  # === CONFIGURATION GIT ===
  programs.git = {
    enable = true;
    userName = "lmandrelli";
    userEmail = "luca.mandrelli@icloud.com"; # Changez par votre email
    
    extraConfig = {
      # Configuration pour une meilleure expérience
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = false;
      
      # Améliore les performances sur les gros repos
      core.preloadindex = true;
      core.fscache = true;
      gc.auto = 256;
    };
    
    # Alias utiles pour Git
    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
      ci = "commit";
      lg = "log --oneline --graph --decorate --all";
    };

    ignores = [
      # direnv
      ".direnv"
      ".envrc"

      # Linux
      "*~"
      ".fuse_hidden*"
      ".directory" 
      ".Trash-*"
      ".nfs*"

      # VSCode
      ".vscode/*"
      "!.vscode/settings.json"
      "!.vscode/tasks.json"
      "!.vscode/launch.json"
      "!.vscode/extensions.json"
      "!.vscode/*.code-snippets"
      ".history/"
      "*.vsix"
      ".history"
      ".ionide"

      # Nix
      "result"
      "result-*"
      ".direnv/"

      # Zed
      ".zed/"

      # Editor/IDE
      ".idea/"
      "*.swp"
      "*.swo"
      "*~"
      ".*.sw[a-z]"

      "AGENTS.md"
    ];
  };

  # === CONFIGURATION ZSH ===
  programs.zsh = {
    enable = true;
    
    # Configuration de base avec suggestions et coloration syntaxique
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    # Historique amélioré
    history = {
      size = 10000;
      save = 10000;
      extended = true; # Horodatage des commandes
      ignoreDups = true;
      ignoreSpace = true; # Ignore les commandes commençant par un espace
    };
    
    # Variables d'environnement personnalisées
    sessionVariables = {
      EDITOR = "nano"; # Éditeur par défaut
      BROWSER = "firefox"; # Navigateur par défaut
    };
    
    # Alias utiles
    shellAliases = {
      # Raccourcis système
      ll = "ls -alF";
      la = "ls -A";
      l = "ls -CF";
      
      # Git raccourcis
      g = "git";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";
      
      # NixOS spécifiques
      nrs = "sudo nixos-rebuild switch --flake .";
      nrt = "sudo nixos-rebuild test --flake .";
      hms = "home-manager switch --flake .";
      
      # Docker raccourcis
      d = "docker";
      dc = "docker-compose";
      dps = "docker ps";
      dpa = "docker ps -a";
      di = "docker images";
      dl = "docker logs";
      de = "docker exec -it";
      dr = "docker run";
      ds = "docker stop";
      drm = "docker rm";
      drmi = "docker rmi";
      
      # Navigation rapide
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
    };
    
    # Configuration oh-my-zsh pour une expérience enrichie
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell"; # Thème simple et efficace
      plugins = [
        "git"           # Aliases et completion Git
        "sudo"          # Double ESC pour ajouter sudo
        "direnv"        # Support direnv
        "command-not-found" # Suggestions de packages
      ];
    };
  };

  # === CONFIGURATION SSH ===
  # Pas de programs.ssh pour éviter les problèmes de permissions avec les symlinks

  # === CONFIGURATION DIRENV ===
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true; # Support nix-shell automatique
  };

  # === CONFIGURATION HYPRLAND ===
  # Configuration inspirée de mylinuxforwork/dotfiles
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    
    # Configuration Hyprland avec style ML4W
    settings = {
      # === CONFIGURATION MONITEUR ===
      monitor = [
        ",preferred,auto,1" # Détection automatique, changez selon vos besoins
      ];
      
      # === PROGRAMMES DE DÉMARRAGE ===
      # Inspiré de ML4W dotfiles avec applications personnalisées
      exec-once = [
        "waybar"                    # Barre de statut
        "mako"                      # Notifications  
        "swww init"                 # Fond d'écran avec support animations
        "swayidle -w timeout 300 'swaylock-effects' timeout 600 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on' before-sleep 'swaylock-effects'"
        "wl-paste --type text --watch cliphist store"    # Gestionnaire presse-papiers
        "wl-paste --type image --watch cliphist store"   # Images presse-papiers
      ];
      
      # === CONFIGURATION ENVIRONNEMENT ===
      # Variables d'environnement inspirées de ML4W
      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
        "QT_QPA_PLATFORM,wayland"
        "QT_QPA_PLATFORMTHEME,qt5ct"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "QT_AUTO_SCREEN_SCALE_FACTOR,1"
        "MOZ_ENABLE_WAYLAND,1"
        "GDK_BACKEND,wayland,x11"
        # Fix for X11 apps on Wayland
        "XDG_SESSION_TYPE,wayland"
        "WAYLAND_DISPLAY,wayland-1"
        "CLUTTER_BACKEND,wayland"
        "SDL_VIDEODRIVER,wayland"
      ];
      
      # === CONFIGURATION INPUT ===
      input = {
        kb_layout = "fr";           # Clavier français
        kb_variant = "";
        kb_model = "";
        kb_options = "";
        kb_rules = "";
        
        follow_mouse = 1;
        
        touchpad = {
          natural_scroll = false;
        };
        
        sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
      };
      
      # === CONFIGURATION GÉNÉRALE ===
      # Améliorations inspirées de ML4W
      general = {
        gaps_in = 6;
        gaps_out = 12;
        border_size = 2;
        
        # Couleurs des bordures (style ML4W moderne)
        "col.active_border" = "rgba(ca9ee6ff) rgba(f2d5cfff) 45deg";
        "col.inactive_border" = "rgba(b4befecc) rgba(6c7086cc) 45deg";
        
        resize_on_border = true;
        allow_tearing = false;
        no_border_on_floating = false;
        
        layout = "dwindle";
      };
      
      # === CONFIGURATION DÉCORATION ===
      # Décorations améliorées style ML4W
      decoration = {
        rounding = 12;
        
        active_opacity = 1.0;
        inactive_opacity = 0.95;
        fullscreen_opacity = 1.0;
        
        drop_shadow = true;
        shadow_range = 6;
        shadow_render_power = 3;
        "col.shadow" = "rgba(181825aa)";
        "col.shadow_inactive" = "rgba(181825dd)";
        
        # Effets de flou avancés
        blur = {
          enabled = true;
          size = 5;
          passes = 3;
          ignore_opacity = true;
          new_optimizations = true;
          vibrancy = 0.1696;
        };
        
        # Dim des fenêtres inactives
        dim_inactive = true;
        dim_strength = 0.1;
      };
      
      # === CONFIGURATION ANIMATIONS ===
      animations = {
        enabled = true;
        
        # Courbes d'animation fluides
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };
      
      # === LAYOUT DWINDLE ===
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };
      
      # === GESTES ===
      gestures = {
        workspace_swipe = false;
      };
      
      # === CONFIGURATION PÉRIPHÉRIQUES ===
      device = [
        {
          name = "epic-mouse-v1";
          sensitivity = -0.5;
        }
      ];
      
      # === RACCOURCIS CLAVIER ===
      "$mod" = "SUPER";
      
      bind = [
        # Applications principales
        "$mod, Q, exec, kitty"                    # Terminal
        "$mod, C, killactive,"                    # Fermer fenêtre
        "$mod, M, exit,"                          # Quitter Hyprland
        "$mod, E, exec, dolphin"                  # Gestionnaire de fichiers
        "$mod, V, togglefloating,"                # Mode flottant
        "$mod, R, exec, wofi --show drun"         # Lanceur d'applications
        "$mod, P, pseudo,"                        # Pseudotiling
        "$mod, J, togglesplit,"                   # Changer orientation split
        
        # Navigation entre fenêtres
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"
        
        # Navigation entre workspaces
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"
        
        # Déplacer fenêtres vers workspaces
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"
        
        # Workspace spécial (scratchpad)
        "$mod, S, togglespecialworkspace, magic"
        "$mod SHIFT, S, movetoworkspace, special:magic"
        
        # Navigation workspaces avec molette souris
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"
        
        # Captures d'écran (style ML4W)
        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy && notify-send 'Capture d'écran' 'Zone sélectionnée copiée'"
        "$mod, Print, exec, grim - | wl-copy && notify-send 'Capture d'écran' 'Écran complet copié'"
        "$mod SHIFT, S, exec, grim -g \"$(slurp)\" ~/Images/screenshot-$(date +%Y%m%d-%H%M%S).png"
        
        # Presse-papiers (ML4W style)
        "$mod, V, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy"
        
        # Applications supplémentaires
        "$mod, T, exec, kitty"
        "$mod, B, exec, firefox"
        "$mod SHIFT, E, exec, wlogout"
        
        # Contrôles multimédia
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
        ", XF86AudioRaiseVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ +5%"
        ", XF86AudioLowerVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ -5%"
        ", XF86AudioMute, exec, pactl set-sink-mute @DEFAULT_SINK@ toggle"
        
        # Contrôle luminosité
        ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
      ];
      
      # Raccourcis de redimensionnement et déplacement
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
      
      # === RÈGLES DE FENÊTRES ===
      windowrulev2 = [
        # Transparence pour certaines applications
        "opacity 0.8 0.8,class:^(kitty)$"
        
        # Applications flottantes
        "float,class:^(pavucontrol)$"
        "float,class:^(bitwarden)$"
        
        # Taille fixe pour certaines applications
        "size 800 600,class:^(pavucontrol)$"
      ];
    };
  };

  # === CONFIGURATION GTK (pour compatibilité KDE) ===
  gtk = {
    enable = true;
    
    theme = {
      name = "Breeze-Dark";
      package = pkgs.kdePackages.breeze-gtk;
    };
    
    iconTheme = {
      name = "breeze-dark";
      package = pkgs.kdePackages.breeze-icons;
    };
    
    cursorTheme = {
      name = "breeze_cursors";
      package = pkgs.kdePackages.breeze;
    };
    
    font = {
      name = "Noto Sans";
      size = 11;
    };
  };

  # === CONFIGURATION XDG ===
  xdg = {
    enable = true;
    
    # Associations de fichiers par défaut
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/about" = "firefox.desktop";
        "x-scheme-handler/unknown" = "firefox.desktop";
        "application/pdf" = "firefox.desktop";
        "image/jpeg" = "org.kde.gwenview.desktop";
        "image/png" = "org.kde.gwenview.desktop";
      };
    };
    
    # Dossiers utilisateur standardisés
    userDirs = {
      enable = true;
      createDirectories = true;
      
      desktop = "${config.home.homeDirectory}/Bureau";
      documents = "${config.home.homeDirectory}/Documents";
      download = "${config.home.homeDirectory}/Téléchargements";
      music = "${config.home.homeDirectory}/Musique";
      pictures = "${config.home.homeDirectory}/Images";
      videos = "${config.home.homeDirectory}/Vidéos";
      templates = "${config.home.homeDirectory}/Modèles";
      publicShare = "${config.home.homeDirectory}/Public";
    };
  };

  # Permet à Home Manager de gérer lui-même ses services
  programs.home-manager.enable = true;

  # === CONFIGURATION NUM LOCK PLASMA ===
  # Service pour activer Num Lock au démarrage de la session KDE
  systemd.user.services.numlock = {
    Unit = {
      Description = "Enable NumLock at startup";
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.numlockx}/bin/numlockx on";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # === GESTION SÉCURISÉE DU TOKEN GITHUB ===
  # Script pour créer le fichier d'environnement avec le token GitHub
  home.file.".config/claude/github-token.sh" = {
    text = ''
      #!/bin/bash
      # Script de configuration du token GitHub pour Claude Code MCP
      # Usage: ./github-token.sh <your-github-token>
      
      if [ -z "$1" ]; then
        echo "Usage: $0 <github-personal-access-token>"
        echo "Créez un token avec les permissions: repo, read:packages"
        exit 1
      fi
      
      TOKEN_FILE="$HOME/.config/claude/.env"
      echo "GITHUB_TOKEN=$1" > "$TOKEN_FILE"
      chmod 600 "$TOKEN_FILE"
      echo "Token GitHub configuré dans $TOKEN_FILE"
      echo "Permissions du fichier: $(ls -la "$TOKEN_FILE")"
    '';
    executable = true;
  };

  # Variables d'environnement pour Claude Code
  home.sessionVariables = {
    # Assurer que les chemins Nix sont disponibles pour MCP
    MCP_PATH = "${config.home.homeDirectory}/.config/claude";
  };

  # === CONFIGURATION HOME-MANAGER ===
  # Suppression automatique des fichiers de sauvegarde existants et correction permissions SSH
  home.activation = {
    removeExistingBackups = config.lib.dag.entryBefore ["checkLinkTargets"] ''
      run rm -f ~/.gtkrc-2.0.hm-backup
      run rm -f ~/.bashrc.hm-backup
      run rm -f ~/.profile.hm-backup
      run rm -f ~/.zshrc.hm-backup
      run rm -f ~/.gitconfig.hm-backup
      run rm -f ~/.ssh/config.hm-backup
    '';
    
    # Fix SSH config permissions for VSCode - copy file instead of symlink
    copySshConfig = let
      sshConfigFile = pkgs.writeText "ssh-config" ''
        # Configuration SSH pour VSCode et git
        Host *
          PasswordAuthentication no
          ChallengeResponseAuthentication no
          HashKnownHosts yes
          VisualHostKey yes
          Compression yes
          ServerAliveInterval 60
          ServerAliveCountMax 3
      '';
    in config.lib.dag.entryAfter ["writeBoundary"] ''
      run mkdir -p ~/.ssh
      run chmod 700 ~/.ssh
      $DRY_RUN_CMD install -m600 -D ${sshConfigFile} $HOME/.ssh/config
    '';
  };
}
