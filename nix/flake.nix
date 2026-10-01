{
  description = "Craig's Home Network Flake";

  inputs = {
    # NixOS packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Darwin packages
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix Darwin
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    # Nix Homebrew
    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
      inputs.brew-src.follows = "brew-src";
    };
    brew-src = {
      url = "github:Homebrew/brew";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    arthur-ficial-tap = {
      url = "github:arthur-ficial/homebrew-tap";
      flake = false;
    };

    whatcable-tap = {
      url = "github:darrylmorley/homebrew-whatcable";
      flake = false;
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    nix-darwin,
    nix-homebrew,
    # nixpkgs-darwin, the Homebrew sources and taps are consumed by modules via
    # the `inputs` specialArg — not referenced directly here.
    ...
  }: let
    systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
    eachSystem = f: nixpkgs.lib.genAttrs systems (system: f (import nixpkgs {inherit system;}));

    # Shared Home Manager module config for all hosts: the platform's shared
    # home module plus the host's own home.nix.
    hmConfig = platformHome: homeFile: {
      home-manager = {
        backupFileExtension = "bak";
        useGlobalPkgs = true;
        useUserPackages = true;
        users.craig.imports = [platformHome homeFile];
        extraSpecialArgs = {inherit inputs;};
      };
    };

    unstablePkgs = system:
      import nixpkgs-unstable {
        inherit system;
        config = {
          allowUnfree = true;
          cudaSupport = true;
          cudaCapabilities = ["6.1"];
        };
      };

    allowUnfree = {nixpkgs.config.allowUnfree = true;};

    # Every host gets its platform's shared system module plus
    # hosts/<name>/{configuration,home}.nix.
    mkNixos = host: {system}:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
          unstable = unstablePkgs system;
        };
        modules = [
          allowUnfree
          ./modules/system/linux.nix
          ./hosts/${host}/configuration.nix
          home-manager.nixosModules.home-manager
          (hmConfig ./modules/home/linux.nix ./hosts/${host}/home.nix)
        ];
      };

    mkDarwin = host: _:
      nix-darwin.lib.darwinSystem {
        specialArgs = {
          inherit inputs;
          unstable = unstablePkgs "aarch64-darwin";
        };
        modules = [
          allowUnfree
          ./modules/system/darwin.nix
          ./hosts/${host}/configuration.nix
          home-manager.darwinModules.home-manager
          (hmConfig ./modules/home/darwin.nix ./hosts/${host}/home.nix)
          nix-homebrew.darwinModules.nix-homebrew
        ];
      };
  in {
    # Newer `nix fmt` passes no arguments, which makes bare alejandra wait on
    # stdin; default to formatting the current directory instead.
    formatter = eachSystem (pkgs:
      pkgs.writeShellScriptBin "alejandra-fmt" ''
        exec ${pkgs.alejandra}/bin/alejandra "''${@:-.}"
      '');

    # `nix flake check` ignores darwinConfigurations entirely. Force each Mac
    # host to evaluate from every system's checks (without building it), so
    # Darwin breakage fails the check on Linux and macOS alike.
    checks = eachSystem (pkgs:
      nixpkgs.lib.mapAttrs' (name: cfg:
        nixpkgs.lib.nameValuePair "darwin-${name}-eval"
        (pkgs.writeText "darwin-${name}-eval" (builtins.unsafeDiscardStringContext cfg.system.drvPath)))
      self.darwinConfigurations);

    devShells = eachSystem (pkgs: {
      default = pkgs.mkShell {
        packages = [pkgs.git pkgs.gh pkgs.prek pkgs.alejandra pkgs.statix pkgs.deadnix];

        # Lets .hooks/nix-devshell.sh skip a nested `nix develop`.
        HOME_NETWORK_DEVSHELL = "1";

        shellHook = ''
          if git rev-parse --show-toplevel >/dev/null 2>&1; then
            repo_root=$(git rev-parse --show-toplevel)
            if [ -f "$repo_root/.pre-commit-config.yaml" ]; then
              (cd "$repo_root" && prek install --hook-type pre-commit >/dev/null)
            fi
          fi
        '';
      };
    });

    nixosConfigurations = builtins.mapAttrs mkNixos {
      s1 = {system = "x86_64-linux";};
      s2 = {system = "aarch64-linux";};
    };

    darwinConfigurations = builtins.mapAttrs mkDarwin {
      d2 = {};
      r2 = {};
    };
  };
}
