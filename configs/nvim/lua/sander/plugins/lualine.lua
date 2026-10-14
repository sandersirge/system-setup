-- Josean set the file-format symbol to the Apple logo (macOS). Here: one block for the line endings
-- (Tux / Windows logo) and a separate block with the logo of the OS this Neovim runs on.
local function current_os_icon()
  if vim.fn.has("win32") == 1 then
    return "\u{e70f}" -- Windows
  end
  local id = ""
  local f = io.open("/etc/os-release", "r")
  if f then
    id = (f:read("*a"):match("\nID=\"?([%w_-]+)") or ""):lower()
    f:close()
  end
  local icons = {
    ubuntu = "\u{f31b}",
    debian = "\u{f306}",
    kali = "\u{f327}",
    arch = "\u{f303}",
    fedora = "\u{f30a}",
  }
  return icons[id] or "\u{f17c}" -- Tux for any other Linux
end
local os_icon = current_os_icon()
return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local lualine = require("lualine")
    local lazy_status = require("lazy.status") -- to configure lazy pending updates count

    local colors = {
      blue = "#65D1FF",
      green = "#3EFFDC",
      violet = "#FF61EF",
      yellow = "#FFDA7B",
      red = "#FF4A4A",
      fg = "#c3ccdc",
      bg = "#112638",
      inactive_bg = "#2c3043",
    }

    local my_lualine_theme = {
      normal = {
        a = { bg = colors.blue, fg = colors.bg, gui = "bold" },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg },
      },
      insert = {
        a = { bg = colors.green, fg = colors.bg, gui = "bold" },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg },
      },
      visual = {
        a = { bg = colors.violet, fg = colors.bg, gui = "bold" },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg },
      },
      command = {
        a = { bg = colors.yellow, fg = colors.bg, gui = "bold" },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg },
      },
      replace = {
        a = { bg = colors.red, fg = colors.bg, gui = "bold" },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg },
      },
      inactive = {
        a = { bg = colors.inactive_bg, fg = colors.semilightgray, gui = "bold" },
        b = { bg = colors.inactive_bg, fg = colors.semilightgray },
        c = { bg = colors.inactive_bg, fg = colors.semilightgray },
      },
    }

    -- configure lualine with modified theme
    lualine.setup({
      options = {
        theme = my_lualine_theme,
      },
      sections = {
        lualine_x = {
          {
            lazy_status.updates,
            cond = lazy_status.has_updates,
            color = { fg = "#ff9e64" },
          },
          { "encoding" },
          -- line endings: Tux = LF (unix), Windows = CRLF (dos), Apple = CR (old mac)
          { "fileformat", symbols = { unix = "\u{e712}", dos = "\u{e70f}", mac = "\u{e711}" } },
          -- OS this Neovim runs on (Windows, or the WSL/Linux distro)
          { function() return os_icon end },
          { "filetype" },
        },
      },
    })
  end,
}
