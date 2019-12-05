{}:

let
  nixpkgsConfig = {
    #allowUnfree = true;
    # allowBroken = true;
  };

  pinnedNixpkgsSrc = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/99e96faee364924a08b4c8b7121292b81020a239.tar.gz";
    # Get this info from the output of: `nix-prefetch-url --unpack $url` where `url` is the above.
    sha256 = "0lgmv0kmrhhz3crl63blgh6k1skgd97aqrkxw30g4bfgig1rldx5";
  };

  pinnedNixpkgs = import pinnedNixpkgsSrc { config = nixpkgsConfig; };
in

pinnedNixpkgs
