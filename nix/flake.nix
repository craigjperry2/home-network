{
  description = "Craig's Home Network Flake";

  inputs = {
    # NixOS packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Darwin packages
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix Darwin
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
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

    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    nix-darwin,
    nix-homebrew,
    # self, nixpkgs-darwin, arthur-ficial-tap, brew-src, homebrew-core, and
    # homebrew-cask are consumed by modules via `inputs` specialArg — not
    # referenced directly here.
    ...
  }: let
    systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
    eachSystem = f: nixpkgs.lib.genAttrs systems (system: f (import nixpkgs {inherit system;}));

    # Shared Home Manager module config for all hosts
    hmConfig = homeFile: {
      home-manager = {
        backupFileExtension = "bak";
        useGlobalPkgs = true;
        useUserPackages = true;
        users.craig = import homeFile;
        extraSpecialArgs = {inherit inputs;};
      };
    };

    unstablePkgs = system:
      import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };

    allowUnfree = {nixpkgs.config.allowUnfree = true;};
  in {
    formatter = eachSystem (pkgs: pkgs.alejandra);

    devShells = eachSystem (pkgs: {
      default = pkgs.mkShell {
        packages = [pkgs.statix pkgs.deadnix];
      };
    });

    nixosConfigurations = {
      s1 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          unstable = unstablePkgs "x86_64-linux";
        };
        modules = [
          allowUnfree
          ./modules/system/linux.nix
          ./hosts/s1/configuration.nix
          home-manager.nixosModules.home-manager
          (hmConfig ./hosts/s1/home.nix)
        ];
      };
      s2 = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = {
          inherit inputs;
          unstable = unstablePkgs "aarch64-linux";
        };
        modules = [
          allowUnfree
          ./modules/system/linux.nix
          ./hosts/s2/configuration.nix
          home-manager.nixosModules.home-manager
          (hmConfig ./hosts/s2/home.nix)
        ];
      };
    };

    darwinConfigurations = {
      d2 = nix-darwin.lib.darwinSystem {
        specialArgs = {
          inherit inputs;
          unstable = unstablePkgs "aarch64-darwin";
        };
        modules = [
          allowUnfree
          ./hosts/d2/configuration.nix
          home-manager.darwinModules.home-manager
          (hmConfig ./hosts/d2/home.nix)
          nix-homebrew.darwinModules.nix-homebrew
        ];
      };

      r2 = nix-darwin.lib.darwinSystem {
        specialArgs = {
          inherit inputs;
          unstable = unstablePkgs "aarch64-darwin";
        };
        modules = [
          allowUnfree
          ./hosts/r2/configuration.nix
          home-manager.darwinModules.home-manager
          (hmConfig ./hosts/r2/home.nix)
          nix-homebrew.darwinModules.nix-homebrew
        ];
      };
    };
  };
}
