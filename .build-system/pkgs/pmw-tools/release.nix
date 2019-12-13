{ pkgs ? null } @ args:

let
  pkgs = (import ../../../.nix/release.nix {}).ensurePkgs args;
in

with pkgs;

let
  pythonPackages = python3Packages;

  default = pythonPackages.callPackage ./. {};

  dev = default.overrideAttrs (oldAttrs: {
    buildInputs = oldAttrs.buildInputs
      ++ (with pythonPackages; [
        pytest
        mypy
        flake8
        ipython
        autopep8
        isort
      ]);

    shellHook = with nsf-py-nix-lib; with nsf-shc-nix-lib; ''
      ${nsfPy.shell.runSetuptoolsShellHook "${builtins.toString ./.}" default}
      ${nsfShC.shell.loadClickExesBashCompletion [ "pmw-tools" ]}

      source ${nsfPy.shell.shellHookLib}
      nsf_py_set_interpreter_env_from_path

      # Fix the "ModuleNotFoundError: No module named 'yaml'" crash
      # observed with recent version of nixpkgs. For some reason,
      # our local 'src' directory is not longer added automatically
      # to 'PYTHONPATH' as it was before.
      nsf_py_add_local_pkg_src_if_present "${builtins.toString ./src}"
    '';
  });

in

rec {
  inherit default;

  shell = {
    installed = mkShell {
      name = "${default.pname}-installed-shell";

      buildInputs = [ default ];

      shellHook = with nsf-shc-nix-lib; ''
        ${nsfShC.env.exportXdgDataDirsOf ([ default ] ++ default.buildInputs)}
        ${nsfShC.env.ensureDynamicBashCompletionLoaderInstalled}
      '';
    };

    dev = mkShell rec {
      name = "${default.pname}-dev-shell";

      PYTHONPATH = "";
      MYPYPATH = "";

      inputsFrom = [
        dev
      ];
    };
  };
}
