-- WezTerm config for Windows, based on josean-dev/dev-environment-files/.wezterm.lua
-- Install: copy to %USERPROFILE%\.wezterm.lua (WezTerm reloads it on save)
local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Josean's "coolnight" colors (unchanged)
config.colors = {
	foreground = "#CBE0F0",
	background = "#011423",
	cursor_bg = "#47FF9C",
	cursor_border = "#47FF9C",
	cursor_fg = "#011423",
	selection_bg = "#033259",
	selection_fg = "#CBE0F0",
	ansi = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#0FC5ED", "#a277ff", "#24EAF7", "#24EAF7" },
	brights = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#A277FF", "#a277ff", "#24EAF7", "#24EAF7" },
}

-- Windows: the Nerd Font already installed for Windows Terminal (his: MesloLGS Nerd Font Mono, 19 on macOS)
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 13

-- Start in WSL Ubuntu (Neovim, tmux); PowerShell 7 is in the launcher (right-click the + tab button)
config.default_domain = "WSL:Ubuntu"
config.launch_menu = {
	{ label = "PowerShell 7", domain = { DomainName = "local" }, args = { "pwsh.exe", "-NoLogo" } },
}

-- Extra keys (defaults still work: Ctrl+Shift+T new tab, Ctrl+Tab next, Ctrl+Shift+W close, Ctrl+Shift+P palette)
config.keys = {
	-- Ctrl+Alt+P: new PowerShell 7 tab
	{ key = "p", mods = "CTRL|ALT", action = wezterm.action.SpawnCommandInNewTab({ domain = { DomainName = "local" }, args = { "pwsh.exe", "-NoLogo" } }) },
	-- Ctrl+Alt+L: launcher (all WSL distros, PowerShell 7, ...)
	{ key = "l", mods = "CTRL|ALT", action = wezterm.action.ShowLauncher },
}

-- His config hides the tab bar (tmux handles tabs); on Windows we keep it only when 2+ tabs are open
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true

-- His "RESIZE" removes the title bar entirely, which leaves no way to drag/close the window on Windows.
-- Keep the normal Windows title bar (minimize / maximize / close).
config.window_decorations = "TITLE|RESIZE"
-- config.window_background_opacity = 0.8
-- config.win32_system_backdrop = "Acrylic"   -- Windows equivalent of macos_window_background_blur

return config
