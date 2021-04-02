{ pkgs, pkgsSrc, extraContainer, extra-container-src }:

let
  config = pkgs.substituteAll
    {
      name = "sway-config";
      src = ./config;
      background = ./bg-basic.png;
      term = "${pkgs.kitty}/bin/kitty";
      conky-config = let
        conky-config = pkgs.substituteAll
          {
            name = "conky-config.conf";
            src = ./conky.conf;
            color1 = "A9A9A9";
            color3 = "616161";
          };
      in
        conky-config;
      termconfig = pkgs.writeText "kitty" ''
        background_opacity 0
        font_size 8.0
        window_padding_width 20

      '';
  };

  #container = builtins.path { path = ./container.nix; name = "container"; };
  container = pkgs.writeText "container" ''
  {
    containers.demo = {
      privateNetwork = true;
      hostAddress = "10.250.0.1";
      localAddress = "10.250.0.2";

      config = { pkgs, ... }: {
        systemd.services.hello = {
          wantedBy = [ "multi-user.target" ];
          script = "
            while true; do
              echo hello | ${pkgs.netcat}/bin/nc -lN 50
            done
          ";
        };
        services.tor = {
          enable = true;
          client = {
            enable = true;
          };
        };
        networking.firewall.allowedTCPPorts = [ 50 9050 ];
      };
    };
  }
  '';

  custom-python-pkgs = python-packages: with python-packages; [
    i3ipc
  ];
  python-pkgs = pkgs.python38.withPackages custom-python-pkgs;


  #layout = pkgs.writeText "layout" '' ${builtins.readFile ./ws-1.py} '';
  #layout = builtins.readFile ./ws-1.py;
  layout = builtins.path {
    path = ./ws-1.py;
    name = "ws-1.py";
  };

  utils = builtins.path {
    path = ./util;
    name = "extra-container-utils";
  };

  includedPackages =
    let pkgsList = map (x: "--prefix PATH : ${x}/bin ")
      [
        pkgs.hello
        extraContainer
        pkgs.ranger
        pkgs.bpytop
        pkgs.conky
        python-pkgs
      ];
    in
      toString pkgsList;

in

pkgs.symlinkJoin {
  name = "nixway-app";
  paths = with pkgs; [ sway waybar hello ranger bpytop conky ];
  buildInputs = with pkgs; [ makeWrapper nixos-container ];
    # if ! test -e /etc/NIXOS; then
    #   sh ${utils}/install.sh
    # fi
  postBuild = ''

    [[ -e /run/booted-system/nixos-version ]] && isNixos=1 || isNixos=
    [[ -e /run/systemd/system ]] && hasSystemd=1 || hasSystemd=
    scriptDir=${utils}

    if [[ $EUID == 0 ]]; then
      echo "This script should NOT be run as root."
      exit 1
    fi
    if [[ $isNixos ]]; then
      echo "This install script is not needed on NixOS. See the README for installation instructions."
      exit 1
    fi
    if [[ ! $hasSystemd ]]; then
      echo "extra-container requires systemd."
      exit 1
    fi
    if [[ ! -e /nix/var/nix/profiles/default ]]; then
      echo "extra-container requires a multi-user nix installation."
      exit 1
    fi

    mv $out/bin/sway $out/bin/nixway-app
    wrapProgram $out/bin/nixway-app \
    --add-flags "--config ${config}" \
    ${includedPackages} \
    --run "${extraContainer}/bin/extra-container create --nixpkgs-path ${pkgsSrc} --start ${container}" \

  '';
  #     --run "${python-pkgs}/bin/python ${layout}"
  #    --run "nixos-container start foo"

}
