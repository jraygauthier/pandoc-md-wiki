{}:

let
  nixpkgsConfig = {
    #allowUnfree = true;
    # allowBroken = true;
  };

  pinnedNixpkgsSrc = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/96c9578020133fe64feab90c00f3cb880d53ad0d.tar.gz";
    # Get this info from the output of: `nix-prefetch-url --unpack $url` where `url` is the above.
    sha256 = "03rn7gn8r129a8cj527nhs7k28ibzwqw083iirwvas2x4k9mir9z";
  };

  pinnedNixpkgs = import pinnedNixpkgsSrc { config = nixpkgsConfig; };
in

pinnedNixpkgs
