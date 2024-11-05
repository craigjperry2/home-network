#!/bin/sh

nix-shell -p zip -p unzip --command 'zip -r collected.zip ~/collect.sh /etc/nixos/configuration.nix ~/.config/hypr ~/.config/waybar ; unzip -l collected.zip'

cat collected.zip | ssh craig@d2.home.craigjperry.com 'mv r3-nixos.zip r3-nixos.1.zip ; cat - > r3-nixos.zip'

