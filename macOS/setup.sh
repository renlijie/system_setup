#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./setup.sh [--update]

Install the macOS development tools and this repository's Vim/Zsh configs.
If Homebrew is missing, the script can install it after confirmation.
Use --update to fast-forward an existing clean Oh My Zsh checkout.
Existing configuration files are backed up before they are replaced.
EOF
}

UPDATE_COMPONENTS=false
while (($#)); do
  case "$1" in
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

if [[ $(uname -s) != Darwin ]]; then
  echo "This setup script supports macOS only." >&2
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  printf 'Homebrew is not installed. Its official installer may request your password and install Xcode Command Line Tools.\n'
  if ! read -r -p "Install Homebrew now? [Y/n] " INSTALL_HOMEBREW; then
    printf 'Unable to read the Homebrew installation prompt response.\n' >&2
    exit 1
  fi
  case "$INSTALL_HOMEBREW" in
    ""|y|Y|yes|YES|Yes)
      ;;
    n|N|no|NO|No)
      printf 'Homebrew installation was declined.\n' >&2
      exit 1
      ;;
    *)
      printf 'Please answer Y or n.\n' >&2
      exit 2
      ;;
  esac

  if ! command -v curl >/dev/null 2>&1; then
    printf 'curl is required to download the official Homebrew installer.\n' >&2
    exit 1
  fi
  HOMEBREW_INSTALLER=$(mktemp "${TMPDIR:-/tmp}/homebrew-install.XXXXXX")
  trap 'rm -f "$HOMEBREW_INSTALLER"' EXIT
  curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o "$HOMEBREW_INSTALLER"
  /bin/bash "$HOMEBREW_INSTALLER"
  rm -f "$HOMEBREW_INSTALLER"
  trap - EXIT
fi

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
COMMON_DIR=$(cd -- "$SCRIPT_DIR/../common" && pwd)

BREW=
case "$(uname -m)" in
  arm64)
    if [[ -x /opt/homebrew/bin/brew ]]; then
      BREW=/opt/homebrew/bin/brew
    fi
    ;;
  x86_64)
    if [[ -x /usr/local/bin/brew ]]; then
      BREW=/usr/local/bin/brew
    fi
    ;;
esac
if [[ -z $BREW ]]; then
  BREW=$(command -v brew || true)
fi
if [[ -z $BREW ]]; then
  if [[ -x /opt/homebrew/bin/brew ]]; then
    BREW=/opt/homebrew/bin/brew
  elif [[ -x /usr/local/bin/brew ]]; then
    BREW=/usr/local/bin/brew
  else
    printf 'Homebrew installation completed, but the brew command was not found.\n' >&2
    exit 1
  fi
fi

BREW_PREFIX=$("$BREW" --prefix)
PATH="$BREW_PREFIX/bin:$BREW_PREFIX/sbin:$PATH"
export PATH

PROFILE="$HOME/.zprofile"
BREW_SHELLENV_LINE="eval \"\$($BREW_PREFIX/bin/brew shellenv)\""
if [[ ! -f $PROFILE ]] || ! grep -Fqx "$BREW_SHELLENV_LINE" "$PROFILE"; then
  printf '\n%s\n' "$BREW_SHELLENV_LINE" >> "$PROFILE"
  printf 'Added Homebrew shell setup to %s\n' "$PROFILE"
fi

backup_path() {
  local target=$1
  local timestamp backup suffix=0

  timestamp=$(date +%Y%m%d%H%M%S)
  backup="${target}.bak.${timestamp}"
  while [[ -e $backup || -L $backup ]]; do
    suffix=$((suffix + 1))
    backup="${target}.bak.${timestamp}.${suffix}"
  done
  cp -a "$target" "$backup"
  printf 'Backed up %s to %s\n' "$target" "$backup"
}

install_config() {
  local source=$1 target=$2

  if [[ -d $target && ! -L $target ]]; then
    printf 'Refusing to replace directory with config file: %s\n' "$target" >&2
    return 1
  fi
  if [[ -f $target ]] && cmp -s "$source" "$target"; then
    printf 'Already up to date: %s\n' "$target"
    return
  fi
  if [[ -e $target || -L $target ]]; then
    backup_path "$target"
    rm "$target"
  fi
  install -m 0644 "$source" "$target"
  printf 'Installed %s\n' "$target"
}

install_oh_my_zsh() {
  local target="$HOME/.oh-my-zsh"

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
  git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git "$target"
}

echo "Installing Homebrew packages..."
"$BREW" install fzf git vim

install_oh_my_zsh
install_config "$COMMON_DIR/_vimrc" "$HOME/.vimrc"
install_config "$COMMON_DIR/_zshrc" "$HOME/.zshrc"

"$BREW_PREFIX/opt/fzf/install" --key-bindings --completion --no-update-rc

printf '\nSetup complete. Open a new Terminal window to use the configuration.\n'
printf 'For Agnoster prompt icons, install a Nerd Font and select it in Terminal settings.\n'
