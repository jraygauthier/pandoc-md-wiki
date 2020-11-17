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
