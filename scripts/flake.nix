{
  description = "Python development environment for scripts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
    eachSystem = f: nixpkgs.lib.genAttrs systems (system: f (import nixpkgs {inherit system;}));
  in {
    devShells = eachSystem (pkgs: {
      default = pkgs.mkShell {
        packages = [
          pkgs.python3
          pkgs.uv
          pkgs.ruff
          pkgs.mypy
        ];
        # mypy and its compiled deps (librt) come from nixpkgs via PYTHONPATH,
        # so uv must use the matching interpreter, not a uv-managed Python.
        env = {
          UV_PYTHON = pkgs.python3.interpreter;
          UV_PYTHON_DOWNLOADS = "never";
        };
      };
    });
  };
}
