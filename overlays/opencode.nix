final: prev: {
  opencode = final.callPackage ({ lib, stdenv, stdenvNoCC, buildGoModule, bun, fetchFromGitHub, makeBinaryWrapper, models-dev, writableTmpDirAsHomeHook }: let
    bun-target = {
      "aarch64-darwin" = "bun-darwin-arm64";
      "aarch64-linux" = "bun-linux-arm64";
      "x86_64-darwin" = "bun-darwin-x64";
      "x86_64-linux" = "bun-linux-x64";
    };
  in stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "opencode";
    version = "0.15.2";
    src = fetchFromGitHub {
      owner = "sst";
      repo = "opencode";
      tag = "v${finalAttrs.version}";
      hash = "sha256-oH0WVQpq+OOMooV21p2gR/WLDtrf9wdKvOZ5fLtzqPk=";
    };

    tui = buildGoModule {
      pname = "opencode-tui";
      inherit (finalAttrs) version src;

      modRoot = "packages/tui";

      vendorHash = "sha256-g3+2q7yRaM6BgIs5oIXz/u7B84ZMMjnxXpvFpqDePU4=";

      subPackages = [ "cmd/opencode" ];

      env.CGO_ENABLED = 0;

      ldflags = [
        "-s"
        "-X=main.Version=${finalAttrs.version}"
      ];

      installPhase = ''
        runHook preInstall

        install -Dm755 $GOPATH/bin/opencode $out/bin/tui

        runHook postInstall
      '';
    };

    node_modules = stdenvNoCC.mkDerivation {
      pname = "opencode-node_modules";
      inherit (finalAttrs) version src;

      impureEnvVars = lib.fetchers.proxyImpureEnvVars ++ [
        "GIT_PROXY_COMMAND"
        "SOCKS_SERVER"
      ];

      nativeBuildInputs = [
        bun
        writableTmpDirAsHomeHook
      ];

      dontConfigure = true;

      buildPhase = ''
        runHook preBuild

        export BUN_INSTALL_CACHE_DIR=$(mktemp -d)

        bun install \
          --filter=opencode \
          --force \
          --frozen-lockfile \
          --ignore-scripts \
          --linker=hoisted \
          --no-progress \
          --production

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out/node_modules
        cp -R ./node_modules $out

        runHook postInstall
      '';

      dontFixup = true;

      outputHash =
        {
          x86_64-linux = "sha256-kXsLJ/Ck9epH9md6goCj3IYpWog/pOkfxJDYAxI14Fg=";
          aarch64-linux = "sha256-DHzDyk7BWYgBNhYDlK3dLZglUN7bMiB3acdoU7djbxU=";
          x86_64-darwin = "sha256-OTEK9SV9IxBHrJlf+F4lI7gF0Gtvik3c7d1mp+4a3Zk=";
          aarch64-darwin = "sha256-qlLfus/cyrI0HtwVLTjPTdL7OeIYjmH9yoNKa6YNBkg=";
        }
        .${stdenv.hostPlatform.system};
      outputHashAlgo = "sha256";
      outputHashMode = "recursive";
    };

nativeBuildInputs = [
          bun
          makeBinaryWrapper
          models-dev
        ];

        patches = [
          # Patch `packages/opencode/src/provider/models-macro.ts` to get contents of
          # `_api.json` from the file bundled with `bun build`.
          ./local-models-dev.patch
        ];

        configurePhase = ''
          runHook preConfigure

          cp -R ${finalAttrs.node_modules}/node_modules .

          runHook postConfigure
        '';

        env.MODELS_DEV_API_JSON = "${models-dev}/dist/_api.json";

    buildPhase = ''
      runHook preBuild

      bun build \
        --define OPENCODE_TUI_PATH="'${finalAttrs.tui}/bin/tui'" \
        --define OPENCODE_VERSION="'${finalAttrs.version}'" \
        --compile \
        --target=${bun-target.${stdenvNoCC.hostPlatform.system}} \
        --outfile=opencode \
        ./packages/opencode/src/index.ts \

      runHook postBuild
    '';

    dontStrip = true;

    installPhase = ''
      runHook preInstall

      install -Dm755 opencode $out/bin/opencode

      runHook postInstall
    '';

    postFixup = ''
      wrapProgram $out/bin/opencode \
        --set LD_LIBRARY_PATH "${lib.makeLibraryPath [ stdenv.cc.cc.lib ]}"
    '';

    meta = {
      description = "AI coding agent built for the terminal";
      homepage = "https://github.com/sst/opencode";
      license = lib.licenses.mit;
      platforms = lib.platforms.unix;
      mainProgram = "opencode";
    };
  })) {};
}