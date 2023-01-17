{
  description = "Raspberry Pi Pico Rust starter code for the 2023 SFCF Rust Club.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    crane.url = "github:ipetkov/crane";
    crane.inputs.nixpkgs.follows = "nixpkgs";

    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    crane,
    rust-overlay,
    ...
  }:
  flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          ( import rust-overlay )
        ];
      };

      rustWithThumbv6mTarget = pkgs.rust-bin.nightly.latest.default.override {
        targets = [ "thumbv6m-none-eabi" ];
      };

      craneLib = (crane.mkLib pkgs).overrideToolchain rustWithThumbv6mTarget;

      rust-rpi-pico-start = craneLib.buildPackage {
        src = craneLib.cleanCargoSource ./.;

        cargoExtraArgs = "--target thumbv6m-none-eabi";

        doCheck = false;

        buildInputs = with pkgs; [
          elf2uf2-rs
        ] ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
          pkgs.libiconv
        ];
      };
    in {
      checks = {
        inherit rust-rpi-pico-start;
      };

      packages.default = rust-rpi-pico-start;

      devShells.default = pkgs.mkShell {
        inputsFrom = builtins.attrValues self.checks;

        nativeBuildInputs = with pkgs; [
          rustWithThumbv6mTarget

          elf2uf2-rs

          rust-analyzer
          clippy
          rustfmt
        ];
      };
    }
  );
}
