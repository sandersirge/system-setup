-- Closing a tab from the bar: bufferline's default runs `:tabclose`, which fails on the last tab
-- (E784: Cannot close last tab page). Close the tab if there are others, otherwise quit Neovim
-- (`confirm` asks before discarding unsaved changes).
local function close_tab(tabhandle)
  if #vim.api.nvim_list_tabpages() > 1 then
    vim.cmd("tabclose " .. vim.api.nvim_tabpage_get_number(tabhandle))
  else
    vim.cmd("confirm qall")
  end
end

return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  version = "*",
  opts = {
    options = {
      mode = "tabs",
      separator_style = "slant", -- as in the 2024 article (Josean's current repo uses the default "thin")
      close_command = close_tab, -- click on a tab's x
      right_mouse_command = close_tab, -- right-click on a tab
    },
  },
}
