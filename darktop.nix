{ pkgs, nixpkgs, extraContainer, nixGL }:

let
  config = pkgs.substituteAll
    {
      name = "sway-config";
      src = ./sway/config;
      background = ./art/bg-basic.png;
      term = "${pkgs.kitty}/bin/kitty";
      termconfig = builtins.path {
        name = "kitty-config";
        path = ./kitty/kitty.conf;
      };
      waybar = builtins.path {
        name= "waybar";
        path = ./sway/waybar-config;
      };
      waybarstyle = builtins.path {
        name= "waybar-style";
        path = ./sway/waybar.css;
      };
      layout = builtins.path {
        path = ./sway/ws-1.py;
        name = "ws-1.py";
      };
      btmcpu = builtins.path {
        path = ./bottom/cpu.toml;
        name = "btmcpu";
      };
      btmproc = builtins.path {
        path = ./bottom/proc.toml;
        name = "btmproc";
      };

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

  python-with-i3ipc = python-packages: with python-packages; [
    i3ipc
  ];
  python-pkgs = pkgs.python38.withPackages python-with-i3ipc;

  # Let these pkgs be available in darktop's PATH
  includedPackages =
    let pkgsList = with pkgs; map (x: "--prefix PATH : ${x}/bin ")
      [
        nixGL.nixGLIntel
        nixGL.nixVulkanIntel
        extraContainer
        bottom
        cage
        sway
        waybar
        i3status
        zsh
        ranger
        pcmanfm
        mpv
        vlc
        python-pkgs
      ];
    in
      toString pkgsList;

in

pkgs.symlinkJoin {
  name = "darktop";
  paths = with pkgs; [
    extraContainer
    sway
    nixGL.nixGLIntel
    nixGL.nixVulkanIntel
  ];
  buildInputs = with pkgs; [ makeWrapper nixos-container ];

  postBuild = ''

    mv $out/bin/nixGLIntel $out/bin/darktop
    wrapProgram $out/bin/sway \
    --add-flags "--config ${config}" \
    ${includedPackages} \
    --run "$out/bin/extra-container create --nixpkgs-path ${nixpkgs} --start ${container}" \

    wrapProgram $out/bin/darktop \
     --add-flags "$out/bin/sway"

  '';
  #     --run "${python-pkgs}/bin/python ${layout}"
}
