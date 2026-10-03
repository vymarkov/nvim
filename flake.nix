{
  description = "Neovim configuration dependencies";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;

        # Runtime tools for Neovim (wrapped PATH only — not exposed as package bins)
        nvimDeps = with pkgs; [
          # Core system tools
          git
          curl
          wget
          unzip
          gnutar
          gzip
          gnumake
          gcc
          cargo

          # Language runtimes
          nodejs
          python3

          # Search and file tools
          fzf
          fd
          ripgrep
          jq

          # Language servers
          lua-language-server
          nodePackages.typescript-language-server
          nodePackages.vscode-langservers-extracted # html, css, json, eslint
          nodePackages.yaml-language-server
          terraform-ls

          # Formatters
          stylua
          shfmt
          nodePackages.prettier
          prettierd
          taplo
          hclfmt

          # Tree-sitter CLI (for nvim-treesitter)
          tree-sitter

          # Git tools (for lazygit integration)
          lazygit
        ];

        # Minimal dependencies subset
        minimalDeps = with pkgs; [
          neovim
          git
          curl
          fzf
          fd
          ripgrep
          jq
        ];
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [ pkgs.neovim ] ++ nvimDeps;

          shellHook = ''
            echo "Neovim development environment loaded!"
            echo ""
            echo "Available tools:"
            echo "  • Neovim: $(nvim --version | head -1)"
            echo "  • Node.js: $(node --version)"
            echo "  • Python: $(python3 --version)"
            echo ""

            echo "Note: This flake only provides dependencies for Neovim plugins."
            echo "    It does not manage plugins or configuration in a pure Nix way."
            echo "    Plugins are managed by Lazy.nvim at runtime."
            echo "Language servers and formatters are available in PATH."
            echo "Run 'nvim' to start your configured Neovim setup."
            echo ""

            export NVIM_CONFIG_DIR="$PWD"
            export MASON_DISABLE_INSTALL="1"
          '';
        };

        # Alternative shell with minimal dependencies (just Neovim + core tools)
        devShells.minimal = pkgs.mkShell {
          buildInputs = minimalDeps;

          shellHook = ''
            echo "Minimal Neovim environment loaded!"
            echo "Note: Language servers will be installed via Mason."
            echo ""
            echo "Note: This flake only provides dependencies for Neovim plugins."
            echo "    It does not manage plugins or configuration in a pure Nix way."
            echo "    Plugins are managed by Lazy.nvim at runtime."
          '';
        };

        # Installable package exposes only the nvim binary; tools stay on wrapped PATH.
        # name/mainProgram must be "nvim" so `nix run` finds $out/bin/nvim.
        packages.default = pkgs.symlinkJoin {
          name = "nvim";
          paths = [ pkgs.neovim ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          meta.mainProgram = "nvim";

          postBuild = ''
            # Keep only the nvim entrypoint (neovim also ships nvim-python3 helpers)
            find $out/bin -mindepth 1 -maxdepth 1 ! -name nvim -exec rm -f {} +

            wrapProgram $out/bin/nvim \
              --prefix PATH : "${lib.makeBinPath nvimDeps}" \
              --set-default NVIM_CONFIG_DIR "$PWD" \
              --set MASON_DISABLE_INSTALL "1"
          '';
        };

        apps.default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/nvim";
        };
      });
}
