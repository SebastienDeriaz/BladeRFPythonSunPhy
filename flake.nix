# BladeRFPythonSunPhy
# Sébastien Deriaz
# 07.02.2023

{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    flake-utils.url = "github:numtide/flake-utils";
    nix-filter.url = "github:numtide/nix-filter";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = inputs: inputs.flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      inherit pkgs;

      devShells.default = pkgs.mkShell.override
        {
          stdenv = pkgs.stdenvNoCC;
        }
        {
          nativeBuildInputs = with pkgs; [
            libbladeRF
          ];
        };
    });
}

