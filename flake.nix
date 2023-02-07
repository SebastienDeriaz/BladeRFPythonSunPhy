# BladeRFPythonSunPhy
# Sébastien Deriaz
# 07.02.2023

{
  inputs = {
    #nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    nixpkgs.url = "github:SebastienDeriaz/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    nix-filter.url = "github:numtide/nix-filter";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    sunphy.url = "github:SebastienDeriaz/sun_phy";
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
            (python310.withPackages
              (pkgs: with pkgs; [
                sun-phy
              ])
            )
          ];
        };
    });
}

