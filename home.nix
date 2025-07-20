# Configuration Home Manager pour lmandrelli
{ config, pkgs, inputs, ... }:

{
  # === INFORMATIONS UTILISATEUR ===
  home = {
    username = "lmandrelli";
    homeDirectory = "/home/lmandrelli";
    stateVersion = "25.05"; # Version de home-manager (alignée sur NixOS)
  };

  # === PACKAGES UTILISATEUR ===
  # Applications et outils spécifiques à l'utilisateur
  home.packages = with pkgs; [
    # === POLICES ===
    jetbrains-mono nerd-fonts.jetbrains-mono nerd-fonts.meslo-lg

    # === DÉVELOPPEMENT ===
    # Rust et son écosystème
    rustc cargo rustfmt clippy
    
    # Node.js et outils JavaScript/TypeScript
    nodejs nodePackages.npm nodePackages.prettier
    bun # Runtime JavaScript moderne et rapide
    
    # Java Development Kit
    jdk # ou jdk21 selon vos besoins
    
    # Python avec support des environnements virtuels
    python3 python3Packages.virtualenv python3Packages.pip
    
    # === ÉDITEURS ET IDE ===
    # Visual Studio Code - éditeur populaire avec extensions
    vscode-fhs # Version avec support FHS pour une meilleure compatibilité
    
    # Zed - éditeur moderne écrit en Rust
    zed-editor

    # Claude Code - commande IA pour IDE
    claude-code
    
    # === TERMINAUX ===
    # Warp - terminal moderne avec IA intégrée (version stable)
    stable.warp-terminal
    
    # Kitty - terminal rapide avec support GPU
    kitty
    
    # === APPLICATIONS DE COMMUNICATION ===
    # Discord pour la communication gaming/développement
    discord
    
    # === MULTIMÉDIA ===
    # Spotify pour la musique en streaming
    spotify
    
    # Cider - client Apple Music alternatif
    cider
    
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
  ];

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

      # Roo Code
      ".roo"
      ".roorules"
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
      EDITOR = "code"; # Éditeur par défaut
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
  programs.ssh = {
    enable = true;
  };

  # Gestion explicite du fichier ~/.ssh/config (Home Manager gère les permissions automatiquement)
  home.file.".ssh/config".text = ''
    # Sécurité renforcée
    Host *
      PasswordAuthentication no
      ChallengeResponseAuthentication no
      HashKnownHosts yes
      VisualHostKey yes

      # Performance
      Compression yes
      ServerAliveInterval 60
      ServerAliveCountMax 3
  '';

  # === CONFIGURATION DIRENV ===
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true; # Support nix-shell automatique
  };

  # === CONFIGURATION HYPRLAND ===
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    
    # Configuration de base Hyprland
    settings = {
      # === CONFIGURATION MONITEUR ===
      monitor = [
        ",preferred,auto,1" # Détection automatique, changez selon vos besoins
      ];
      
      # === PROGRAMMES DE DÉMARRAGE ===
      exec-once = [
        "waybar"                    # Barre de statut
        "mako"                      # Notifications
        "swww init"                 # Fond d'écran
        "swayidle -w timeout 300 'swaylock' timeout 600 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on' before-sleep 'swaylock'"
      ];
      
      # === CONFIGURATION ENVIRONNEMENT ===
      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
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
      general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;
        
        # Couleurs des bordures (thème sombre moderne)
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        
        resize_on_border = false;
        allow_tearing = false;
        
        layout = "dwindle";
      };
      
      # === CONFIGURATION DÉCORATION ===
      decoration = {
        rounding = 10;
        
        active_opacity = 1.0;
        inactive_opacity = 1.0;
        
        drop_shadow = true;
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";
        
        # Effets de flou moderne
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
          
          vibrancy = 0.1696;
        };
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
        
        # Captures d'écran
        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"
        "$mod, Print, exec, grim - | wl-copy"
        
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

  # === CONFIGURATION GTK ===
  gtk = {
    enable = true;
    
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    
    cursorTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    
    font = {
      name = "Sans";
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
}
