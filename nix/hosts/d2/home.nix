{ config, pkgs, ... }:

{
  imports = [
    ../../modules/home/core.nix
  ];

  home.username = "craig";
  home.homeDirectory = "/Users/craig";
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    delta
    ffmpeg
    flac
    iperf3
    kubectl
    libwebp
    nmap
    pnpm
    procs
    tokei
    uv
    wget
    yt-dlp
    zellij
    zulu
  ];

  programs.direnv.stdlib = ''
    layout_uv() {
        if [[ -d ".venv" ]]; then
            VIRTUAL_ENV="$(pwd)/.venv"
        fi

        if [[ -z $VIRTUAL_ENV || ! -d $VIRTUAL_ENV ]]; then
            log_status "No virtual environment exists. Executing `uv venv` to create one."
            uv venv
            VIRTUAL_ENV="$(pwd)/.venv"
        fi

        uv sync

        if [ -d ".venv/bin" ]; then
            PATH_add .venv/bin
        fi

        export UV_ACTIVE=1  # or VENV_ACTIVE=1
        export VIRTUAL_ENV
    }
  '';

  programs.zsh.shellAliases = {
    ckill = "ps -ef | awk \"/501.*Citrix/{print $2}\" | xargs kill";
    sec = "nvim ~/Code/github.com/craigjperry2/home-network/nix/hosts/d2/configuration.nix";
    seh = "nvim ~/Code/github.com/craigjperry2/home-network/nix/hosts/d2/home.nix";
    sns = "( cd ~/Code/github.com/craigjperry2/home-network/nix ; sudo darwin-rebuild switch --flake .#d2 )";
    uu = "( cd ~/Code/github.com/craigjperry2/home-network/nix ; nix flake update ); sns";
  };
}
