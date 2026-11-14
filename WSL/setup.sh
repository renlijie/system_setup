#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./setup.sh [--update]

Install the base WSL development tools and this repository's Vim/Zsh configs.
fzf is always installed from its upstream repository.
Use --update to fast-forward existing clean upstream checkouts.
Existing configuration files are backed up before they are replaced.
EOF
}

UPDATE_COMPONENTS=false
while (($#)); do
  case "$1" in
    --with-fzf)
      # Retained as a no-op for compatibility; fzf is always installed.
      ;;
    --update)
      UPDATE_COMPONENTS=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown option: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

if [[ $EUID -eq 0 ]]; then
  echo "Run this script as your regular WSL user, not as root." >&2
  exit 1
fi

if [[ ! -r /etc/os-release ]]; then
  echo "Cannot identify this Linux distribution." >&2
  exit 1
fi
# shellcheck disable=SC1091
source /etc/os-release
if [[ ${ID:-} != ubuntu ]]; then
  echo "This setup script supports Ubuntu on WSL." >&2
  exit 1
fi
if [[ -z ${WSL_DISTRO_NAME:-} ]] && ! grep -qiE '(microsoft|wsl)' /proc/sys/kernel/osrelease; then
  echo "This setup script is intended to run inside WSL." >&2
  exit 1
fi
if ! command -v sudo >/dev/null 2>&1; then
  echo "sudo is required to install system packages." >&2
  exit 1
fi

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

backup_path() {
  local target=$1
  local timestamp backup suffix=0

  timestamp=$(date +%Y%m%d%H%M%S)
  backup="${target}.bak.${timestamp}"
  while [[ -e $backup || -L $backup ]]; do
    suffix=$((suffix + 1))
    backup="${target}.bak.${timestamp}.${suffix}"
  done
  cp -a -- "$target" "$backup"
  printf 'Backed up %s to %s\n' "$target" "$backup"
}

install_config() {
  local source=$1 target=$2

  if [[ -d $target && ! -L $target ]]; then
    printf 'Refusing to replace directory with config file: %s\n' "$target" >&2
    return 1
  fi
  if [[ -f $target ]] && cmp -s -- "$source" "$target"; then
    printf 'Already up to date: %s\n' "$target"
    return
  fi
  if [[ -e $target || -L $target ]]; then
    backup_path "$target"
    rm -- "$target"
  fi
  install -m 0644 -- "$source" "$target"
  printf 'Installed %s\n' "$target"
}

clone_if_missing() {
  local url=$1 target=$2

  if [[ -d $target && ( -d "$target/.git" || -f "$target/.git" ) ]]; then
    if [[ $UPDATE_COMPONENTS == true ]]; then
      if [[ -n $(git -C "$target" status --porcelain) ]]; then
        printf 'Refusing to update checkout with local changes: %s\n' "$target" >&2
        return 1
      fi
      git -C "$target" pull --ff-only
    else
      printf 'Using existing checkout: %s\n' "$target"
    fi
    return
  fi
  if [[ -e $target || -L $target ]]; then
    printf 'Refusing to overwrite non-git path: %s\n' "$target" >&2
    return 1
  fi
  git clone --depth 1 "$url" "$target"
}

echo "Installing Ubuntu packages..."
sudo apt-get update
packages=(ca-certificates curl git python3 python3-venv vim zsh)
sudo apt-get install -y "${packages[@]}"

clone_if_missing https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"

clone_if_missing https://github.com/junegunn/fzf.git "$HOME/.fzf"

install_config "$SCRIPT_DIR/_vimrc" "$HOME/.vimrc"
install_config "$SCRIPT_DIR/_zshrc" "$HOME/.zshrc"

"$HOME/.fzf/install" --key-bindings --completion --no-update-rc

ZSH_PATH=$(command -v zsh)
if ! grep -Fxq "$ZSH_PATH" /etc/shells; then
  printf 'Zsh is not listed as a valid login shell in /etc/shells: %s\n' "$ZSH_PATH" >&2
  exit 1
fi
USER_NAME=$(id -un)
sudo chsh -s "$ZSH_PATH" "$USER_NAME"
if [[ $(getent passwd "$USER_NAME" | cut -d: -f7) != "$ZSH_PATH" ]]; then
  printf 'Failed to set %s as the login shell for %s.\n' "$ZSH_PATH" "$USER_NAME" >&2
  exit 1
fi

printf '\nSetup complete. Zsh is now your login shell; open a new WSL terminal to use it.\n'
printf '\nAgnoster font setup (on Windows, not inside WSL):\n'
printf '1. Download Meslo Nerd Font: https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip\n'
printf '2. Install MesloLGSNerdFontMono-Regular.ttf (and optional bold/italic styles).\n'
printf '3. Set Windows Terminal > Ubuntu profile > Appearance > Font face to "MesloLGS Nerd Font Mono".\n'
