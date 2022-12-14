{ pkgs, fetchFromGitHub, python3, stdenv, gdb, lib }:

with pkgs;
let
  mach-nix = import
    (builtins.fetchGit {
      url = "https://github.com/DavHau/mach-nix";
      ref = "refs/tags/3.5.0";
    })
    { };

  filterLine = filter: text: lib.lists.fold
    (lines: next_line: lines + "\n" + next_line)
    ""
    (builtins.filter
      filter
      (lib.strings.splitString "\n" text)
    );

  python_env = mach-nix.mkPython rec {
    requirements =
      filterLine (line: !(lib.strings.hasInfix "file://" line))
        (filterLine (line: !(lib.strings.hasInfix "--only-binary" line))
          (builtins.readFile ./esp-idf/requirements.txt)) + ''
        esptool
        pyserial
      '';
  };
in
stdenv.mkDerivation rec {
  name = "esp-idf";

  nativeBuildInputs = [ pkgs.makeWrapper ];

  buildInputs = with pkgs; [
    ninja
    cmake
    ccache
    dfu-util
    python_env
  ];

  src = fetchFromGitHub {
    owner = "espressif";
    repo = "esp-idf";
    rev = "7edc3e878fc42aecf9606c584ff1122a0ae2059d"; # v4.4.3
    fetchSubmodules = true;
    sha256 = "sha256-37ilQ9w0XDZwVDrodoRowMa9zcDuzBYk1hSSOO8ooXY=";
  };

  phases = [ "installPhase" ];

  installPhase = ''
    makeWrapper ${python_env}/bin/python $out/bin/idf.py \
    --add-flags ${src}/tools/idf.py \
    --set IDF_PATH ${src} \
    --prefix PATH : "${lib.makeBinPath buildInputs}"
  '';

  shellHook = ''
    export IDF_PATH=${src}
    export PATH=$IDF_PATH/tools:$PATH
    export IDF_PYTHON_ENV_PATH=${python_env}
  '';

  inherit python_env;
}