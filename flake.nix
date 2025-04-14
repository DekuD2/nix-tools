{
  description = "My personal tools for simplifying development.";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs-unstable, flake-utils }:
  flake-utils.lib.eachDefaultSystem (system:
  let
    unstable = nixpkgs-unstable.legacyPackages.${system};
    tclock = unstable.rustPlatform.buildRustPackage rec {
      pname = "tclock";
      version = "0.5.0";
      src = fetchTarball {
        url = "https://github.com/race604/clock-tui/tarball/master";
        sha256 = "1w1lb5k32r58n9cxazbz5rjxjsv7pk83p5brvxdc0anh0dsbwxyk";
      };
      cargoLock.lockFile = "${src}/Cargo.lock";
    };
  in
  {
    packages.tclock = tclock;
    lib = {
      mk_prepare_venv = {python-with-packages, venvDir ? ".venv"}: ''
        # Create virtualenv if doesn't exist
        if test ! -d "./${venvDir}"; then
          echo "creating venv..."
          virtualenv "./${venvDir}" --python="${python-with-packages}/bin/python3" --system-site-packages
          export PYTHONHOME="${python-with-packages}"  # This has to be set AFTER creating virtualenv but BEFORE installing requirements. That is because the --system-site-packages tells the virtualenv to use system packages when they are available (such as the tricky numpy package).

          if test -f requirements.txt; then
            echo "installing dependencies... ('pip install -r requirements.txt')"
            ${venvDir}/bin/pip install -r requirements.txt
          fi
          if test -f setup.py || test -f pyproject.toml; then
            echo "installing dependencies... ('pip install -e .')"
            ${venvDir}/bin/pip install -e .
          fi
        fi

        export PYTHONHOME="${python-with-packages}"
      '';
    };
  }
  );
}

