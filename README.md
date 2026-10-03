# My Neovim Configuration

This is my personal Neovim setup, tailored for a fast and minimal development workflow focused on **Node.js/TypeScript** and **DevOps** (YAML, Terraform/HCL, shell, JSON).

## Installation

### Option 1: Traditional Installation

1. Clone the repo:

   ```bash
   git clone https://github.com/marianozunino/nvim.git ~/.config/nvim
   ```

2. Set up Git hooks (optional but recommended):
   If you'd like to automatically format Lua files before committing, configure Git to use the custom `.githooks` directory:

   ```bash
   git config core.hooksPath .githooks
   ```

3. Make sure that `stylua` is installed via Mason:

   ```bash
   :MasonInstall stylua
   ```

   This configuration relies on `stylua` being installed by Mason at `~/.local/share/nvim/mason/bin/stylua`.

4. Open Neovim:

   ```bash
   nvim
   ```

### Option 2: Nix Flake Installation (Recommended)

This repository includes a Nix flake that provides Neovim with language tools on a **wrapped PATH**. The installable package exposes **only** the `nvim` binary.

1. Clone the repo:

   ```bash
   git clone https://github.com/marianozunino/nvim.git ~/.config/nvim
   cd ~/.config/nvim
   ```

2. Enter the Nix development shell:

   ```bash
   nix develop
   ```

   Or for a minimal environment (tools installed via Mason):

   ```bash
   nix develop .#minimal
   ```

3. (Optional) Use direnv for automatic environment loading:

   ```bash
   echo "use flake" > .envrc
   direnv allow
   ```

4. Open Neovim:

   ```bash
   nvim
   ```

#### What's Included in the Nix Flake

The flake provides (as private runtime deps for wrapped `nvim` / `nix develop`):

- **Core tools**: Neovim, Git, curl, unzip, make, gcc
- **Language runtimes**: Node.js, Python3
- **Search tools**: fzf, fd, ripgrep, jq
- **Language servers**: lua-language-server, typescript-language-server, vscode-langservers-extracted (html/json), yaml-language-server, terraform-ls
- **Formatters**: stylua, shfmt, prettier/prettierd, taplo, hclfmt
- **Additional tools**: lazygit, tree-sitter

#### Flake Commands

```bash
# Enter development shell with all dependencies on PATH
nix develop

# Enter minimal shell (Mason will install language servers)
nix develop .#minimal

# Build / run — only the nvim binary is exposed
nix build
nix run
ls result/bin   # should show only: nvim
```

   ![Neovim Setup](pic.jpg)

## License

This configuration is available under the [MIT License](LICENSE).
