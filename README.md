# Neovim config overlay

LazyVim base + personal customizations (monokai-pro spectrum colorscheme, no italics, custom highlight overrides).

## Install on a new machine

1. Install Neovim 0.11+ and a Nerd Font.
2. Install LazyVim starter: `git clone https://github.com/LazyVim/starter ~/.config/nvim && rm -rf ~/.config/nvim/.git`
3. Copy files from this repo into `~/.config/nvim/`:
   - `lua/config/*.lua` → `~/.config/nvim/lua/config/`
   - `lua/plugins/*.lua` → `~/.config/nvim/lua/plugins/`
   - `lazy-lock.json` and `lazyvim.json` → `~/.config/nvim/`
4. Launch `nvim`. Lazy will install plugins from the lockfile.
5. If treesitter parsers aren't auto-installed, run `:lua require('nvim-treesitter').install({'go', 'c', 'lua', 'vim'})` (or your languages).
