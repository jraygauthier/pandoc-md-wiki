{ pkgs ? null
, workspaceDir ? null
}:

# When `pkgs == null`, the drawbacks are:
#  -  `nsf-pin` cli tools are not available.
#  -  A pin's `default.nix` file won't be able to receive packages
#     from `pkgs` as input.
# Usually, one should set pkgs to null only when pinning `nixpkgs`
# itself or when one want to avoid using `nixpkgs`.

# When non null, should be a path or if a string, an absolute path.
assert null == workspaceDir
  || (builtins.isPath workspaceDir)
  || ("/" == builtins.substring 0 1 workspaceDir);

let
  pinnedSrcsDir = ./pinned-src;
  nsfp = rec {
    localPath = /. + workspaceDir + "/nsf-pin";
    srcInfoJson = pinnedSrcsDir + "/nsf-pin/channel/default.json";
    srcInfo = builtins.fromJSON (builtins.readFile srcInfoJson);
    channels =
      assert srcInfo.type == "fetchFromGitHub";
      with srcInfo;
      {
        default = rec {
          version = {
            inherit ref rev;
            url = "https://github.com/${owner}/${repo}";
          };
          src = builtins.fetchTarball (with version; {
            url = "${url}/archive/${rev}.tar.gz";
            sha256 = "${srcInfo.sha256}";
          });
        };
      };

    pinnedSrcPath = channels.default.src;
    srcPath =
      if null != workspaceDir
          && builtins.pathExists localPath
        then localPath
        else pinnedSrcPath;

    nixLib = (import (srcPath + "/release.nix") { inherit pkgs; }).nix-lib;
  };
in

rec {
  srcs = nsfp.nixLib.mkSrcDir {
    inherit pinnedSrcsDir;
    inherit workspaceDir;
    srcPureIgnores = {};
    inherit pkgs;
  };

  pickedSrcs =
    builtins.mapAttrs (k: v: v.default) srcs.localOrPinned;

  # This repo's internal overlay.
  overlayInternal = import ./overlay-internal.nix { inherit srcs pickedSrcs; };

  overlayInternalReqs = builtins.attrNames (overlayInternal {} {});

  hasOverlayInternal = pkgs: builtins.all (x: x) (
    builtins.map (
      x: builtins.hasAttr x pkgs)
      overlayInternalReqs
  );

  # The set of overlays used by this repo.
  overlays = [
    overlayInternal
  ];

  # This constitutes our default nixpkgs.
  nixpkgsSrc = pickedSrcs.nixpkgs.src;
  nixpkgs = nixpkgsSrc;

  defaultPkgsConfig = { allowUnfree = false; };
  defaultPkgs = import nixpkgs {config = defaultPkgsConfig;};

  #
  # Both of the following can be used from release files.
  #
  importPkgs = { nixpkgs ? null } @ args:
      let
        nixpkgs =
          if args ? "nixpkgs" && null != args.nixpkgs
            then args.nixpkgs
            else nixpkgsSrc;  # From top level.
      in
    assert null != nixpkgs;
    import nixpkgs { inherit overlays; config = defaultPkgsConfig; };

  ensurePkgs = { pkgs ? null, nixpkgs ? null }:
    if null != pkgs
      then
        if hasOverlayInternal pkgs
          # Avoid extending a `pkgs` that already has our overlays.
          then pkgs
        else
          pkgs.appendOverlays overlays
    else
      importPkgs { inherit nixpkgs; };
}
