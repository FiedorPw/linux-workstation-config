#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS=""

if [[ "$OSTYPE" == "darwin"* ]]; then
  OS="macos"
elif [[ -f /run/host/etc/os-release ]]; then
  # Running inside Flatpak container - read host OS
  . /run/host/etc/os-release
  OS="${ID:-linux}"
elif [[ -f /etc/os-release ]]; then
  . /etc/os-release
  OS="${ID:-linux}"
else
  OS="unknown"
fi

echo "🚀 Starting Installation for: $OS"

# --- 2. INSTALL PACKAGES ---
install_apt() {
  echo "📦 Updating & Installing APT (Advanced Package Tool) packages..."
  sudo apt update
  xargs -a "$DOTFILES_DIR/scripts/packages.apt.txt" sudo apt install -y
}

install_dnf() {
  echo "📦 Installing DNF (Dandified YUM) packages..."
  sudo dnf -y install stow git curl zsh 
  
  # Enable eza Copr repo for Fedora
  if ! dnf repolist | grep -q "alternateved-eza"; then
    echo "📦 Enabling eza Copr repository..."
    sudo dnf copr enable -y alternateved/eza
  fi
  
  # Enable pgdev Copr repo for ghostty
  if ! dnf repolist | grep -q "pgdev-ghostty"; then
    echo "📦 Enabling ghostty Copr repository..."
    sudo dnf copr enable -y pgdev/ghostty
  fi
  
  # Read the file, filter out comments (#) and lines starting with -, then install
  grep -vE "^\s*#|^\s*-|^\s*$" "$DOTFILES_DIR/scripts/packages.dnf.txt" | xargs sudo dnf -y install --skip-unavailable
}

install_kora_icons() {
  echo "🎨 Installing Kora icon theme..."
  mkdir -p ~/.local/share/icons
  
  if [[ ! -d "$HOME/.local/share/icons/kora" ]]; then
    cd /tmp
    git clone https://github.com/bikass/kora.git
    cp -r kora/kora* ~/.local/share/icons/
    rm -rf kora
    echo "   -> Kora icons installed"
  else
    echo "   -> Kora icons already installed"
  fi
}

install_gui_linux() {
  # Prefer Flatpak, fallback to Snap
  if command -v flatpak >/dev/null 2>&1; then
    echo "📦 Installing GUI apps via Flatpak..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    echo -e "\033[0;31m⚠️  Please install Visual Studio Code natively (not via Flatpak)\033[0m"
    flatpak install -y flathub md.obsidian.Obsidian
    flatpak install -y flathub com.jgraph.drawio.desktop
  elif command -v snap >/dev/null 2>&1; then
    echo "📦 Installing GUI apps via Snap (VSCode, Obsidian, Draw.io)..."
    sudo snap install code --classic
    sudo snap install obsidian --classic
    sudo snap install drawio
  else
    echo "⚠️ No Flatpak or Snap found. Skipping VS Code/Obsidian/Draw.io."
  fi
}

install_mac() {
  echo "🍎 Installing Homebrew Packages..."
  if ! command -v brew >/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  # CLI tools
  brew install stow zsh git htop btop bat eza ripgrep fd neofetch nmap rustscan

  # GUI apps (casks)
  brew install --cask visual-studio-code obsidian drawio ghostty zed
}

install_nerd_fonts_linux() {
  echo "🔤 Installing Nerd Fonts on Linux..."
  mkdir -p "$HOME/.local/share/fonts"
  cd "$HOME/.local/share/fonts"
  
  # MesloLGS NF (for powerlevel10k)
  echo "   -> Installing MesloLGS NF..."
  curl -fLo "MesloLGS NF Regular.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
  curl -fLo "MesloLGS NF Bold.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
  curl -fLo "MesloLGS NF Italic.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
  
  # JetBrainsMono Nerd Font (for ghostty)
  echo "   -> Installing JetBrainsMono Nerd Font..."
  JBMONO_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
  curl -fLo /tmp/JetBrainsMono.zip "$JBMONO_URL"
  unzip -o /tmp/JetBrainsMono.zip -d "$HOME/.local/share/fonts/" 2>/dev/null || true
  rm -f /tmp/JetBrainsMono.zip
  
  fc-cache -f -v || true
}

case "$OS" in
  ubuntu|debian|kali|pop)
    install_apt
    install_gui_linux
    install_kora_icons
    ;;
  fedora)
    install_dnf
    install_gui_linux
    install_kora_icons
    ;;
  macos)
    install_mac
    ;;
  *)
    echo "⚠️ Unknown OS '$OS' - skipping package install"
    ;;
esac

# --- 3. ZSH CONFIGURATION ---
echo "⚡ Setting up Zsh..."

# Remove existing .zshrc if it's a regular file (not a symlink)
if [[ -e "$HOME/.zshrc" && ! -L "$HOME/.zshrc" ]]; then
  echo "   -> Backing up existing .zshrc..."
  mv "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%s)"
fi

# stow the config from dotfiles directory
cd "$DOTFILES_DIR"
stow -vt ~ zsh

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
mkdir -p "$ZSH_CUSTOM/plugins" "$ZSH_CUSTOM/themes"

[[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]] || \
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

[[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]] || \
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

[[ -d "$ZSH_CUSTOM/themes/powerlevel10k" ]] || \
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"

# --- 4. LINKING DOTFILES ---
echo "🔗 Linking Configurations..."
mkdir -p "$HOME/.config"

# Avoid blowing away a real .zshrc if it exists (only remove if not a symlink)
if [[ -e "$HOME/.zshrc" && ! -L "$HOME/.zshrc" ]]; then
  rm -f "$HOME/.zshrc"
fi

cd "$DOTFILES_DIR"
stow -R zsh nvim ghostty zed code run-or-raise

# Install VS Code extensions
echo "   -> Installing VS Code extensions..."
if command -v code >/dev/null 2>&1 && [[ -f "$DOTFILES_DIR/code/.config/Code/User/extensions.txt" ]]; then
  while IFS= read -r extension; do
    code --install-extension "$extension" --force 2>/dev/null || true
  done < "$DOTFILES_DIR/code/.config/Code/User/extensions.txt"
fi

# Link BashScripts to ~/Projects/scripts
echo "   -> Linking Custom Scripts..."
mkdir -p "$HOME/Projects"
rm -rf "$HOME/Projects/scripts"
ln -s "$DOTFILES_DIR/bashScripts" "$HOME/Projects/scripts"
chmod -R u+rx "$HOME/Projects/scripts" || true

# --- 5. GNOME RESTORE (Linux Only) ---
if [[ "$OS" != "macos" ]]; then
  echo "🐧 Restoring GNOME (GNU Network Object Model Environment)..."

  EXT_DIR="$HOME/.local/share/gnome-shell/extensions"
  mkdir -p "$EXT_DIR"
  cp -R "$DOTFILES_DIR/gnome/gnome-shell-extensions/"* "$EXT_DIR/" || true

  # Enable GNOME extensions
  echo "   -> Enabling GNOME Shell extensions..."
  if command -v gnome-extensions >/dev/null 2>&1; then
    for ext_dir in "$EXT_DIR"/*/; do
      ext_name=$(basename "$ext_dir")
      if [[ "$ext_name" != "*" ]]; then
        gnome-extensions enable "$ext_name" 2>/dev/null || true
      fi
    done
  fi

  # Set Kora icons as default
  echo "   -> Setting Kora icons as default..."
  if command -v gsettings >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.interface icon-theme 'kora' 2>/dev/null || true
  fi

  # Set Projects folder icon
  echo "   -> Setting Projects folder icon..."
  if command -v gio >/dev/null 2>&1 && [[ -d "$HOME/Projects" ]]; then
    gio set -t string "$HOME/Projects" metadata::custom-icon-name folder-projects 2>/dev/null || true
  fi

  if command -v dconf >/dev/null 2>&1; then
    [[ -f "$DOTFILES_DIR/gnome/gnome-terminal.dconf" ]] && \
      dconf load /org/gnome/terminal/ < "$DOTFILES_DIR/gnome/gnome-terminal.dconf"

    [[ -f "$DOTFILES_DIR/gnome/keybindings.dconf" ]] && \
      dconf load /org/gnome/settings-daemon/plugins/media-keys/ < "$DOTFILES_DIR/gnome/keybindings.dconf"

    [[ -f "$DOTFILES_DIR/gnome/gnome-shell-extensions/gnome-extensions-settings.dconf" ]] && \
      dconf load /org/gnome/shell/extensions/ < "$DOTFILES_DIR/gnome/gnome-shell-extensions/gnome-extensions-settings.dconf"
  fi

  echo "🔄 Applying Key Remapping..."
  bash "$DOTFILES_DIR/scripts/keyremap.sh"
fi

if [[ "$OS" != "macos" ]]; then
  echo "installing nerd fonts"
  install_nerd_fonts_linux
fi

echo "✅ Setup Complete! Please restart your session."
