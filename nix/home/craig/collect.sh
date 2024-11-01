#!/bin/sh

nix-shell -p zip -p unzip --command 'zip -r collected.zip ~/collect.sh /etc/nixos/configuration.nix ~/.config/hypr ~/.config/waybar ; unzip -l collected.zip'

scp collected.zip craig@d2.home.craigjperry.com:r3-nixos.zip

