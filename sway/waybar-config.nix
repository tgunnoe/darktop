{ pkgs }:
{
  layer = "top";
  position = "left";
  width = 60;
  modules-center = [ "sway/window" ];
  modules-left = ["sway/workspaces" "sway/mode" ];
  modules-right = ["clock"];
  clock = {
    format-alt = "{:%a, %d. %b  %H:%M}";
    tooltip = false;
  };
  "custom/quit" = {
        format = "";
        on-click = "swaynag -f 'Terminus (TTF)'  -t warning -m 'Do you really want to exit sway?' -b 'Yes, exit sway' 'swaymsg exit'";
      };

}
