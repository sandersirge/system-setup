-- Enabled as in the 2024 article (Josean's current repo has this file commented out)
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 500 -- popup appears 500 ms after a prefix key such as <Space>
  end,
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  },
}
