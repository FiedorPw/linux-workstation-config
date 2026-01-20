# Fedora Dotfiles & Setup

Automated Fedora Workstation setup with GNOME, Ghostty terminal, Neovim, and custom configurations. Uses GNU Stow for symlink management.

## 🚀 Quick Install

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/Projects/config
cd ~/Projects/config
./install.sh
```

Then **log out and log back in** to apply GNOME extensions and settings.

## ✨ What's Included

- **Terminal**: Ghostty with custom config, toggle (Ctrl+Alt+T), split (Ctrl+D), close (Ctrl+W)
- **Shell**: Zsh + Oh My Zsh + Powerlevel10k + plugins
- **Editor**: Neovim with full config
- **Icons**: Kora icon theme
- **Fonts**: MesloLGS NF + JetBrainsMono Nerd Font
- **CLI Tools**: eza, bat, ripgrep, fd-find, btop, fastfetch, etc.
- **GNOME Extensions**: All your extensions auto-installed and enabled
- **Keybindings**: Custom shortcuts for quick navigation

## 🎯 Features

### Keybindings
- `Ctrl+Alt+T` - Toggle/focus Ghostty terminal
- `Ctrl+Alt+H` - Open home folder
- `Ctrl+Alt+P` - Open Projects folder
- `Ctrl+Alt+F` - Open Downloads
- `Ctrl+Alt+Z` - Screenshots folder
- `Ctrl+Alt+X` - Screencasts folder

### Ghostty Terminal
- `Ctrl+D` - Split pane right
- `Ctrl+Shift+D` - Split pane down
- `Ctrl+W` - Close current pane
- `Ctrl+Shift+Arrow` - Navigate between panes

### Installed Tools
```bash
# Modern CLI replacements
ls → eza (with icons)
cat → bat (syntax highlighting)
find → fd
grep → rg (ripgrep)
top → btop
fetch → fastfetch

# Network & Security
nmap, wireshark, rustscan

# Development
neovim, git, gcc, make, python3, ruby, nodejs
```

### Custom Scripts (~/Projects/scripts)
| Script | Description |
|--------|-------------|
| `cpld [n]` | Copy last `n` files from Downloads to current directory (default: 1) |
| `path` | Copy current working directory path to clipboard |
| `copy` | Pipe content to clipboard (e.g., `cat file \| copy`) |
| `gitpas` | Copy GitHub PAT to clipboard (from `~/.github_token`) |

### ThinkPad Key Remapping
Uses [keyd](https://github.com/rvaiya/keyd) to remap keys for better ThinkPad experience:
- `Home` → `End`
- `End` → `Home`  
- `Insert` → `Delete`
- `PgUp/PgDn` swapped for more intuitive navigation

Config: [scripts/keyd/default.conf](scripts/keyd/default.conf)

## 📁 Structure

```
~/Projects/config/
├── install.sh           # Main installation script
├── bashScripts/         # Custom scripts (linked to ~/Projects/scripts)
├── ghostty/             # Terminal config (.config/ghostty)
├── gnome/               # GNOME settings & extensions
├── nvim/                # Neovim configuration (.config/nvim)
├── run-or-raise/        # Run-or-raise shortcuts (.config/run-or-raise)
├── scripts/             # Package lists & utilities
├── zed/                 # Zed editor config (.config/zed)
└── zsh/                 # Zsh + Oh My Zsh config
```

## 🔧 Manual Stow Usage

```bash
# Stow individual configs
stow -vt ~ nvim          # Links ~/.config/nvim
stow -vt ~ ghostty       # Links ~/.config/ghostty
stow -vt ~ run-or-raise  # Links ~/.config/run-or-raise

# Restow (update symlinks)
stow -Rvt ~ nvim ghostty zsh
```

## 🔄 Updating Dotfiles

After making changes, commit and push:
```bash
cd ~/Projects/config
git add -A
git commit -m "Update configs"
git push
```

On another machine, just pull and re-run install.sh:
```bash
cd ~/Projects/config
git pull
./install.sh
```

## 📋 Supported Distributions

- **Fedora** (primary target)
- **Ubuntu/Debian/Pop!_OS**
- **macOS** (partial support)

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

Open ~/.zshrc, find the line that sets ZSH_THEME, and change its value to "powerlevel10k/powerlevel10k".




0) How “Linux user config” is layered (XDG model)

System-wide defaults in /etc and /usr/share (owned by root). Example: /etc/zsh/zshrc.

Per-user config in your home, mostly via XDG Base Dirs:

XDG_CONFIG_HOME → ~/.config (configs)

XDG_DATA_HOME → ~/.local/share (data/plugins)

XDG_STATE_HOME → ~/.local/state (state)

XDG_CACHE_HOME → ~/.cache (caches)

GNOME apps/preferences use GSettings(dconf) (binary key–value store). The on-disk DB is ~/.config/dconf/user, but you usually export/import subtrees instead of copying that file blindly.

With that, here’s where each of your targets actually lives.

1) GNOME custom shortcuts (and general GNOME prefs)

Live in dconf, primarily under:

/org/gnome/settings-daemon/plugins/media-keys/

Custom shortcuts are enumerated by the key
org.gnome.settings-daemon.plugins.media-keys custom-keybindings → list of paths like
/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ (each has name, binding, command).

What to copy (manual-friendly)
Best practice is to export the subtree to a text file you can version/control:

dconf dump /org/gnome/settings-daemon/plugins/media-keys/ > ~/backup/gnome-media-keys.dconf


You can surgically edit this file or restore just this subtree:

dconf load /org/gnome/settings-daemon/plugins/media-keys/ < ~/backup/gnome-media-keys.dconf

2) GNOME Shell extensions (code + their settings)

Extension code (per-user installs):
~/.local/share/gnome-shell/extensions/<uuid>/ (each has a metadata.json).
Copy these folders to carry the exact extension versions you downloaded manually.

System-wide extensions (installed by apt): /usr/share/gnome-shell/extensions/ (don’t copy; re-install packages instead).

Which extensions are enabled (and extension preferences):

Enabled list: GSettings key org.gnome.shell enabled-extensions.

Most extension prefs live in dconf under /org/gnome/shell/extensions/...

What to copy

# extension code (user installs)
rsync -a ~/.local/share/gnome-shell/extensions/ ~/backup/gnome-shell-extensions/

# the enabled list and per-extension settings
gsettings get org.gnome.shell enabled-extensions > ~/backup/gnome-enabled-extensions.txt
dconf dump /org/gnome/shell/extensions/ > ~/backup/gnome-extensions-settings.dconf


Restore (manual): copy the dirs back to ~/.local/share/gnome-shell/extensions/, then:

gsettings set org.gnome.shell enabled-extensions "$(cat ~/backup/gnome-enabled-extensions.txt)"
dconf load /org/gnome/shell/extensions/ < ~/backup/gnome-extensions-settings.dconf


Note: extension settings are in dconf; only copying the code won’t restore prefs.

3) Zsh and shell environment

Dotfiles (per-user):

~/.zshrc (interactive setup, plugins, prompts)

~/.zprofile (login shell env), ~/.zshenv (always sourced, keep it minimal)

Optional: ~/.p10k.zsh (powerlevel10k)

Generated caches you usually don’t copy: ~/.zcompdump*

Frameworks/plugins (if used):

~/.oh-my-zsh, ~/.zinit, ~/.zplug, ~/.antigen, ~/.zim, etc.

System-wide (rarely need to copy): /etc/zsh/zshrc, /etc/zsh/zprofile

What to copy

rsync -a ~/.zshrc ~/.zprofile ~/.zshenv ~/.p10k.zsh ~/backup/zsh/ 2>/dev/null
for d in ~/.oh-my-zsh ~/.zinit ~/.zplug ~/.antigen ~/.zim; do
  [ -d "$d" ] && rsync -a "$d" ~/backup/zsh/$(basename "$d")/
done


Restore: drop files back into $HOME, ensure ownership, optionally chsh -s "$(which zsh)".

4) Neovim (nvim)

Config (XDG config): ~/.config/nvim/ (e.g., init.lua, lua/ modules, after/)

Data/plugins (XDG data): ~/.local/share/nvim/

lazy/ (lazy.nvim), site/pack/packer/start/ (packer), mason/ (LSPs/linters/formatters), treesitter/ (parsers)

State (XDG state): ~/.local/state/nvim/ (shada, sessions)

Cache (XDG cache): ~/.cache/nvim/ (bytecode, etc.; optional)

What to copy

rsync -a ~/.config/nvim/       ~/backup/nvim/config/
rsync -a ~/.local/share/nvim/  ~/backup/nvim/share/
rsync -a ~/.local/state/nvim/  ~/backup/nvim/state/    # optional but nice
rsync -a ~/.cache/nvim/        ~/backup/nvim/cache/    # optional


Restore: copy back to the same XDG paths. If you skip share/, your plugin manager will re-install; including it preserves exact pins and Mason tools.

5) GNOME Terminal configuration

All terminal settings are dconf-backed under:
/org/gnome/terminal/legacy/ and /org/gnome/terminal/legacy/profiles:/
Each profile is a UUID subtree with keys like use-theme-colors, palette, font, custom-command, etc.

What to copy

dconf dump /org/gnome/terminal/ > ~/backup/gnome-terminal.dconf


Restore:

dconf load /org/gnome/terminal/ < ~/backup/gnome-terminal.dconf

6) Quick “copy list” (minimal, manual, file-focused)

GNOME shortcuts & prefs → dconf dump /org/gnome/settings-daemon/plugins/media-keys/

GNOME extensions (code) → ~/.local/share/gnome-shell/extensions/

GNOME extensions (prefs) → dconf dump /org/gnome/shell/extensions/

Enabled extensions list → gsettings get org.gnome.shell enabled-extensions

GNOME Terminal → dconf dump /org/gnome/terminal/

Zsh → ~/.zshrc, ~/.zprofile, ~/.zshenv, ~/.p10k.zsh (+ any of ~/.oh-my-zsh, ~/.zinit, ~/.zplug, …)

Neovim → ~/.config/nvim/ (+ ~/.local/share/nvim/, ~/.local/state/nvim/, ~/.cache/nvim/)

7) Practical notes (so you don’t get bit)

Ownership/permissions: when copying as root or between disks, fix perms afterward:

sudo chown -R "$USER:$USER" ~/.config ~/.local ~/.zsh* ~/.oh-my-zsh ~/.zinit ~/.zplug 2>/dev/null || true


GNOME version drift: copying old extension code to a newer GNOME can break. If that happens, reinstall the extension and then apply your settings dump; don’t force old code.

dconf binary vs exports: you can copy ~/.config/dconf/user, but schema drift makes it brittle. Prefer subtree exports shown above.

One-liner verify: list a schema to confirm keys before/after restore:

gsettings list-recursively org.gnome.shell | grep enabled-extensions
gsettings list-recursively org.gnome.settings-daemon.plugins.media-keys | grep custom-keybindings -A3


If you want, I can generate a super-small “just the files” rsync script that mirrors exactly this manual plan with includes/excludes, so your backup folder stays human-readable.

You
