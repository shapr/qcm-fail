{
  description = "qcm-fail";

  inputs = {
    # Nix Inputs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
  };

  outputs = {
    self,
    nixpkgs,
  }: 
    let
      forAllSystems = function:
        nixpkgs.lib.genAttrs [
          "x86_64-linux"
          "aarch64-linux"
          "x86_64-darwin"
          "aarch64-darwin"
        ] (system: function rec {
          inherit system;
          compilerVersion = "ghc963";
          pkgs = nixpkgs.legacyPackages.${system};
          hsPkgs = pkgs.haskell.packages.${compilerVersion}.override {
            overrides = hfinal: hprev: {
              qcm-fail = hfinal.callCabal2nix "qcm-fail" ./. {};
            };
          };
        });
    in
    {
      # nix fmt
      formatter = forAllSystems ({pkgs, ...}: pkgs.alejandra);

      # nix develop
      devShell = forAllSystems ({hsPkgs, pkgs, ...}:
        hsPkgs.shellFor {
          # withHoogle = true;
          packages = p: [
            p.qcm-fail
          ];
          buildInputs = with pkgs;
            [
              hsPkgs.haskell-language-server
              haskellPackages.cabal-install
              cabal2nix
              haskellPackages.ghcid
              haskellPackages.fourmolu
              haskellPackages.cabal-fmt
            ]
            ++ (builtins.attrValues (import ./scripts.nix {s = pkgs.writeShellScriptBin;}));
        });

      # nix build
      packages = forAllSystems ({hsPkgs, ...}: {
          qcm-fail = hsPkgs.qcm-fail;
          default = hsPkgs.qcm-fail;
      });

      # You can't build the qcm-fail package as a check because of IFD in cabal2nix
      checks = {};

      # nix run
      apps = forAllSystems ({system, ...}: {
        qcm-fail = { 
          type = "app"; 
          program = "${self.packages.${system}.qcm-fail}/bin/qcm-fail"; 
        };
        default = self.apps.${system}.qcm-fail;
      });
    };
}
