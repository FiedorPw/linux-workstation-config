local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- shell
config.default_prog = { "/bin/zsh", "-l" }

-- window
config.window_decorations = "NONE"
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.window_close_confirmation = "NeverPrompt"
config.window_background_opacity = 0.96
config.scrollback_lines = 50000
config.alternate_buffer_wheel_scroll_speed = 1
config.enable_wayland = true

-- font
config.font = wezterm.font_with_fallback({
  "JetBrainsMono Nerd Font",
  "Menlo",
})
config.font_size = 11
config.command_palette_font_size = 11

-- colors (HackerGreen from Ghostty)
config.colors = {
  foreground = "#00FF00",
  background = "#000000",
  cursor_bg = "#A0A0A0",
  cursor_fg = "#000000",
  selection_bg = "#1a4a1a",
  selection_fg = "#80FF80",

  -- split separator = same color as text
  split = "#49AEE6",

  ansi = {
    "#808080", -- black
    "#D41919", -- red
    "#5EBDAB", -- green
    "#FEA44C", -- yellow
    "#367BF0", -- blue
    "#9755B3", -- magenta
    "#49AEE6", -- cyan
    "#E6E6E6", -- white
  },
  brights = {
    "#198388", -- bright black
    "#EC0101", -- bright red
    "#47D4B9", -- bright green
    "#FF8A18", -- bright yellow
    "#277FFF", -- bright blue
    "#962AC3", -- bright magenta
    "#05A1F7", -- bright cyan
    "#FFFFFF", -- bright white
  },
}

-- inactive panes stay fully visible
config.inactive_pane_hsb = {
  saturation = 1.0,
  brightness = 0.4,
}

-- Wayland clipboard via wl-copy/wl-paste (fixes persistent copy issues)
local copy_action = wezterm.action_callback(function(window, pane)
  local text = window:get_selection_text_for_pane(pane)
  if text and text ~= "" then
    local handle = io.popen("wl-copy", "w")
    if handle then
      handle:write(text)
      handle:close()
    end
    window:toast_notification("wezterm", "Copied to clipboard", nil, 1500)
  end
end)

local paste_action = wezterm.action_callback(function(window, pane)
  local handle = io.popen("wl-paste --no-newline 2>/dev/null")
  if handle then
    local text = handle:read("*a")
    handle:close()
    if text and text ~= "" then
      pane:paste(text)
    end
  end
end)

-- keybinds (physical Command = Alt via keyd)
config.keys = {
  { key = "c", mods = "ALT", action = copy_action },
  { key = "v", mods = "ALT", action = paste_action },
  { key = "t", mods = "ALT", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
  { key = "w", mods = "ALT", action = wezterm.action.CloseCurrentTab({ confirm = false }) },
  { key = "f", mods = "ALT|CTRL", action = wezterm.action.ToggleFullScreen },

  -- split panes
  { key = "d", mods = "ALT", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "d", mods = "ALT|SHIFT", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "d", mods = "CTRL", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "d", mods = "CTRL|SHIFT", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },

  -- navigate panes
  { key = "LeftArrow", mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Left") },
  { key = "RightArrow", mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Right") },
  { key = "UpArrow", mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Up") },
  { key = "DownArrow", mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Down") },

  -- close pane
  { key = "w", mods = "CTRL|SHIFT", action = wezterm.action.CloseCurrentPane({ confirm = false }) },

  -- Ctrl+Backspace = delete word back (send Ctrl+W)
  { key = "Backspace", mods = "CTRL", action = wezterm.action.SendKey({ key = "w", mods = "CTRL" }) },

  -- Unicode/emoji picker
  { key = "e", mods = "CTRL|SHIFT", action = wezterm.action.CharSelect({ copy_on_select = false }) },
  { key = "u", mods = "CTRL|SHIFT", action = wezterm.action.Nop },
}

return config
