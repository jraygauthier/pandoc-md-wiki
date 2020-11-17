{ pkgs ? (import ./default.nix {}).defaultPkgs  # Can be set `null`.
, workspaceDir ? builtins.toString ../..
}:

import ./default.nix { inherit pkgs workspaceDir; }
