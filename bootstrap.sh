#!/usr/bin/env bash
# Bootstrap script for Neovim config overlay.
# Idempotent: safe to re-run. Works on macOS and Arch Linux (incl. Omarchy).

set -euo pipefail

# ---- Paths -------------------------------------------------------------------
NVIM_DIR="${HOME}/.config/nvim"
NVIM_DATA_DIR="${HOME}/.local/share/nvim"
NVIM_STATE_DIR="${HOME}/.local/state/nvim"
NVIM_CACHE_DIR="${HOME}/.cache/nvim"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Treesitter parsers to install on first run
TS_PARSERS=(bash c go gomod gosum gowork lua markdown markdown_inline python query vim vimdoc yaml json jsonc)

# ---- Helpers -----------------------------------------------------------------
info()  { printf "\033[1;34m==>\033[0m %s\n" "$*"; }
warn()  { printf "\033[1;33m!! \033[0m %s\n" "$*"; }
err()   { printf "\033[1;31mxx \033[0m %s\n" "$*" >&2; }

# Detect OS
case "$(uname -s)" in
  Darwin) OS="mac" ;;
  Linux)  OS="linux" ;;
  *)      err "Unsupported OS: $(uname -s)"; exit 1 ;;
esac
info "Detected OS: ${OS}"

# ---- 1. Ensure Neovim is installed and recent --------------------------------
ensure_neovim() {
  if ! command -v nvim >/dev/null 2>&1; then
    info "Neovim not found; installing..."
    if [[ "${OS}" == "mac" ]]; then
      if ! command -v brew >/dev/null 2>&1; then
        err "Homebrew not found. Install from https://brew.sh first."
        exit 1
      fi
      brew install neovim
    else
      sudo pacman -S --needed --noconfirm neovim
    fi
  fi

  local version major minor
  version="$(nvim --version | head -1 | awk '{print $2}' | sed 's/^v//')"
  major="$(echo "${version}" | cut -d. -f1)"
  minor="$(echo "${version}" | cut -d. -f2)"
  if (( major < 1 )) && (( minor < 11 )); then
    err "Neovim ${version} is too old. Need 0.11+. Please upgrade."
    exit 1
  fi
  info "Neovim ${version} OK"
}

# ---- 2. On Mac, optionally wipe existing config ------------------------------
maybe_wipe_existing_mac_config() {
  if [[ "${OS}" != "mac" ]]; then
    return
  fi
  if [[ ! -d "${NVIM_DIR}" ]]; then
    return
  fi

  if [[ -f "${NVIM_DIR}/init.lua" ]] && [[ -f "${NVIM_DIR}/lua/config/lazy.lua" ]]; then
    info "Existing LazyVim base detected; keeping it."
    return
  fi

  warn "Existing non-LazyVim config detected at ${NVIM_DIR}"
  read -r -p "Wipe it (and ~/.local/share/nvim, ~/.local/state/nvim, ~/.cache/nvim)? [y/N] " ans
  case "${ans}" in
    y|Y|yes|YES)
      info "Wiping..."
      rm -rf "${NVIM_DIR}" "${NVIM_DATA_DIR}" "${NVIM_STATE_DIR}" "${NVIM_CACHE_DIR}"
      ;;
    *)
      err "Aborted. Move ${NVIM_DIR} aside manually and re-run."
      exit 1
      ;;
  esac
}

# ---- 3. Ensure LazyVim base is present ---------------------------------------
ensure_lazyvim_base() {
  if [[ -f "${NVIM_DIR}/init.lua" ]] && [[ -f "${NVIM_DIR}/lua/config/lazy.lua" ]]; then
    info "LazyVim base already present at ${NVIM_DIR}"
    return
  fi

  if [[ -d "${NVIM_DIR}" ]] && [[ -n "$(ls -A "${NVIM_DIR}" 2>/dev/null)" ]]; then
    err "${NVIM_DIR} exists but doesn't look like LazyVim. Refusing to overwrite."
    err "Move it aside (e.g. mv ${NVIM_DIR} ${NVIM_DIR}.backup) and re-run."
    exit 1
  fi

  info "Cloning LazyVim starter into ${NVIM_DIR}"
  git clone https://github.com/LazyVim/starter "${NVIM_DIR}"
  rm -rf "${NVIM_DIR}/.git"
}

# ---- 4. Overlay our customizations -------------------------------------------
overlay_files() {
  info "Overlaying customizations from ${REPO_DIR}"

  local files=(
    "lua/config/options.lua"
    "lua/config/keymaps.lua"
    "lua/config/autocmds.lua"
    "lua/plugins/colorscheme.lua"
    "lazy-lock.json"
    "lazyvim.json"
  )

  for f in "${files[@]}"; do
    local src="${REPO_DIR}/${f}"
    local dst="${NVIM_DIR}/${f}"
    if [[ ! -f "${src}" ]]; then
      warn "Source missing, skipping: ${f}"
      continue
    fi
    mkdir -p "$(dirname "${dst}")"
    cp "${src}" "${dst}"
    info "  ${f}"
  done
}

# ---- 5. Install plugins + treesitter parsers ---------------------------------
install_plugins_and_parsers() {
  info "Installing plugins from lazy-lock.json (this may take a moment)..."
  nvim --headless "+Lazy! restore" "+qa" 2>&1 | tail -5 || true

  info "Installing treesitter parsers: ${TS_PARSERS[*]}"
  local lua_list
  lua_list="$(printf "'%s'," "${TS_PARSERS[@]}")"
  lua_list="{${lua_list%,}}"

  nvim --headless \
    "+lua require('nvim-treesitter').install(${lua_list}):wait()" \
    "+qa" 2>&1 | tail -5 || true
}

# ---- Run ---------------------------------------------------------------------
ensure_neovim
maybe_wipe_existing_mac_config
ensure_lazyvim_base
overlay_files
install_plugins_and_parsers

info "Done. Launch with: nvim"
