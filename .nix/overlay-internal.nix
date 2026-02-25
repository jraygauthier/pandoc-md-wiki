{ srcs
, pickedSrcs
}:
self: super:

let
  nsf-pin = import "${pickedSrcs.nsf-pin.src}/release.nix" {
    pkgs = self;
  };
  nsf-shc = import "${pickedSrcs.nsf-shc.src}/release.nix" {
    pkgs = self;
  };
  nsf-py = import "${pickedSrcs.nsf-py.src}/release.nix" {
    pkgs = self;
  };
in

{
  nsf-shc-nix-lib = nsf-shc.nix-lib;
  nsf-pin-cli = nsf-pin.cli;
  nsf-pin-nix-lib = nsf-pin.nix-lib;
  nsf-py-nix-lib = nsf-py.nix-lib;

  pandoc-ext-include-files = self.callPackage ./pkgs/pandoc-ext-include-files {};
  pandoc-ext-list-table = self.callPackage ./pkgs/pandoc-ext-list-table {};
}
