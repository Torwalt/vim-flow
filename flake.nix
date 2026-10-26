{
  description = "vim-flow: a free Vim game and Bend 2 experiment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    bend = {
      # The v2.0.39 tag's flake still packages 2.0.38; this fixes the archive pin.
      url = "github:bendlang/bend/8bffcdb67ca0d57004f2e4736bb221aff5444d03";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    bend-source = {
      url = "github:bendlang/bend/v2.0.39";
      flake = false;
    };
    claude-code-nix.url = "github:sadjow/claude-code-nix";
    codex-cli-nix.url = "github:sadjow/codex-cli-nix";
    ploopy = {
      url = "github:Torwalt/ploopy";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.claude-code-nix.follows = "claude-code-nix";
    };
    benchpress = {
      url = "github:Torwalt/benchpress";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.claude-code-nix.follows = "claude-code-nix";
      inputs.ploopy.follows = "ploopy";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      bend,
      bend-source,
      claude-code-nix,
      codex-cli-nix,
      ploopy,
      benchpress,
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          bendPackage = bend.packages.${system}.default;
          lean = pkgs.callPackage ./nix/lean.nix { };
          bendtt = pkgs.callPackage ./nix/bendtt.nix {
            inherit lean bendPackage;
          };
        in
        {
          bend = bendPackage;
          inherit lean bendtt;
          default = pkgs.stdenvNoCC.mkDerivation {
            pname = "vim-flow-web";
            version = "0.0.0";
            src = self;
            nativeBuildInputs = [ bendPackage ];
            BEND_NO_TELEMETRY = "1";
            BENDTT = "${bendtt}/bin/bendtt";
            dontConfigure = true;
            buildPhase = ''
              runHook preBuild
              bend PROOF.bend --verdict
              bend index.html -o dist
              runHook postBuild
            '';
            installPhase = ''
              runHook preInstall
              mkdir -p $out
              cp -r dist/. $out/
              runHook postInstall
            '';
          };
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          bendPackage = bend.packages.${system}.default;
        in
        {
          default = pkgs.mkShell {
            packages = [
              bendPackage
              self.packages.${system}.lean
              self.packages.${system}.bendtt
              pkgs.bun
              pkgs.typescript
              pkgs.clang
              pkgs.just
              pkgs.git
              pkgs.ripgrep
              pkgs.jq
              pkgs.nixfmt
              claude-code-nix.packages.${system}.claude-code
              codex-cli-nix.packages.${system}.default
              ploopy.packages.${system}.ploopy
              benchpress.packages.${system}.benchpress
            ]
            ++ pkgs.lib.optional pkgs.stdenv.hostPlatform.isLinux pkgs.chromium;

            BEND_LOADER = "${bend-source}/bend2/main.ts";
            BENDTT = "${self.packages.${system}.bendtt}/bin/bendtt";
            BEND_NO_TELEMETRY = "1";
            PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
            PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH =
              if pkgs.stdenv.hostPlatform.isLinux then "${pkgs.chromium}/bin/chromium" else "";
          };
        }
      );

      checks = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          proofs =
            pkgs.runCommand "vim-flow-proofs"
              {
                nativeBuildInputs = [ bend.packages.${system}.default ];
                BEND_NO_TELEMETRY = "1";
                BENDTT = "${self.packages.${system}.bendtt}/bin/bendtt";
              }
              ''
                bend ${self}/PROOF.bend --verdict
                touch $out
              '';
          web = self.packages.${system}.default;
        }
      );

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);
    };
}
