#!/usr/bin/env bash
set -euo pipefail

# GNOME gsettings customizations

# Sound
gsettings set org.gnome.desktop.sound event-sounds false
gsettings set org.gnome.desktop.sound input-feedback-sounds false

# Appearance
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface icon-theme 'kora'
gsettings set org.gnome.desktop.interface clock-format '24h'

# Window manager
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:close'
gsettings set org.gnome.desktop.wm.preferences num-workspaces 4
gsettings set org.gnome.mutter dynamic-workspaces true
gsettings set org.gnome.mutter edge-tiling false

# Touchpad
gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true
gsettings set org.gnome.desktop.peripherals.touchpad speed -0.29914529914529919
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click false
gsettings set org.gnome.desktop.peripherals.touchpad two-finger-scrolling-enabled true
gsettings set org.gnome.desktop.peripherals.touchpad disable-while-typing false

# Favorite apps (dock)
gsettings set org.gnome.shell favorite-apps "['org.mozilla.firefox.desktop', 'org.wezfurlong.wezterm.desktop', 'org.gnome.Nautilus.desktop', 'windsurf.desktop', 'org.gnome.TextEditor.desktop']"
