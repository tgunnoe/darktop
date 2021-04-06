{ pkgs, nixpkgs, extraContainer, nixGL }:

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
        nixGL.nixGLIntel
        python-pkgs
      ];
    in
      toString pkgsList;

in

pkgs.symlinkJoin {
  name = "darktop";
  paths = with pkgs; [ extraContainer sway waybar hello ranger bpytop conky nixGL.nixGLIntel ];
  buildInputs = with pkgs; [ makeWrapper nixos-container ];

  postBuild = ''

    mv $out/bin/nixGLIntel $out/bin/darktop
    wrapProgram $out/bin/sway \
    --add-flags "--config ${config}" \
    ${includedPackages} \
    --run "${extraContainer}/bin/extra-container create --nixpkgs-path ${nixpkgs} --start ${container}" \

    wrapProgram $out/bin/darktop \
     --add-flags "$out/bin/sway"

  '';
  #     --run "${python-pkgs}/bin/python ${layout}"
  #    --run "nixos-container start foo"

}
