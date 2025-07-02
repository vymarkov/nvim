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

        # Single array of all Neovim dependencies
        nvimDeps = with pkgs; [
          # Core Neovim
          neovim

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
          go
          nodejs
          yarn
          python3

          # Search and file tools
          fzf
          fd
          ripgrep

          # JSON processing
          jq

          # Language servers (some available in nixpkgs)
          gopls
          lua-language-server
          nodePackages.typescript-language-server
          nodePackages.vscode-langservers-extracted # html, css, json, eslint
          nodePackages.yaml-language-server
          graphql-language-service-cli
          omnisharp-roslyn

          # Formatters and linters
          stylua
          shfmt
          nodePackages.prettier
          prettierd
          clang-tools # includes clang-format
          dotnetCorePackages.dotnet_9.sdk
          csharpier # C# formatter

          # Go tools
          gofumpt
          gotools # includes goimports
          golines

          # Additional tools
          perlPackages.LatexIndent
          taplo # TOML formatter

          # Tree-sitter CLI (for nvim-treesitter)
          tree-sitter

          # Git tools (for lazygit integration)
          lazygit

          # Database tools (for vim-dadbod)
          sqlite

          # LaTeX tools (for latexindent)
          texlive.combined.scheme-basic
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
          buildInputs = nvimDeps;

          shellHook = ''
            echo "🚀 Neovim development environment loaded!"
            echo ""
            echo "Available tools:"
            echo "  • Neovim: $(nvim --version | head -1)"
            echo "  • Go: $(go version | cut -d' ' -f3-4)"
            echo "  • Node.js: $(node --version)"
            echo "  • Python: $(python3 --version)"
            echo ""

            echo "⚠️  Note: This flake only provides dependencies for Neovim plugins."
            echo "    It does not manage plugins or configuration in a pure Nix way."
            echo "    Plugins are managed by Lazy.nvim at runtime."
            echo "Language servers and formatters are available in PATH."
            echo "Run 'nvim' to start your configured Neovim setup."
            echo ""

            # Set up some environment variables that might be useful
            export NVIM_CONFIG_DIR="$PWD"
            export MASON_DISABLE_INSTALL="1"  # Prevent Mason from trying to install tools
          '';
        };

        # Alternative shell with minimal dependencies (just Neovim + core tools)
        devShells.minimal = pkgs.mkShell {
          buildInputs = minimalDeps;

          shellHook = ''
            echo "📦 Minimal Neovim environment loaded!"
            echo "Note: Language servers will be installed via Mason."
            echo ""
            echo "⚠️  Note: This flake only provides dependencies for Neovim plugins."
            echo "    It does not manage plugins or configuration in a pure Nix way."
            echo "    Plugins are managed by Lazy.nvim at runtime."
          '';
        };

        # Package for just the dependencies (without shell)
        packages.nvim-deps = pkgs.buildEnv {
          name = "nvim-deps";
          paths = nvimDeps;
        };

        # Default package - Neovim with all dependencies available
        packages.default = pkgs.symlinkJoin {
          name = "nvim-with-deps";
          paths = [ pkgs.neovim ] ++ nvimDeps;
          buildInputs = [ pkgs.makeWrapper ];

          postBuild = ''
            wrapProgram $out/bin/nvim \
              --prefix PATH : "${pkgs.lib.makeBinPath nvimDeps}" \
              --set-default NVIM_CONFIG_DIR "$PWD" \
              --set MASON_DISABLE_INSTALL "1"

            # Create alternative entry points
            # ln -sf $out/bin/nvim $out/bin/nvim-configured
            ln -sf $out/bin/nvim $out/bin/nvim-with-deps
          '';
        };
      });
}
