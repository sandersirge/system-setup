-- telescope-fzf-native is a C library: `make` on Linux; on Windows (no make) compile it with zig into build/libfzf.dll
local fzf_build = vim.fn.has("win32") == 1 and "mkdir build 2>nul & zig cc -O3 -Wall -std=gnu99 -shared src/fzf.c -o build/libfzf.dll"
  or "make"

return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = fzf_build },
    "nvim-tree/nvim-web-devicons",
    -- "folke/todo-comments.nvim" is added in the todo-comments step
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    telescope.setup({
      defaults = {
        path_display = { "smart" },
        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous, -- move to prev result
            ["<C-j>"] = actions.move_selection_next, -- move to next result
            -- <C-q> (quickfix + trouble) and <C-t> (open in trouble) are added in the trouble step
          },
        },
      },
    })

    telescope.load_extension("fzf")

    -- set keymaps
    local keymap = vim.keymap -- for conciseness

    keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
    keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
    keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
    keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
    keymap.set("n", "<leader>fk", "<cmd>Telescope keymaps<cr>", { desc = "Find keymaps" })
    -- <leader>ft (find todos) is added in the todo-comments step
  end,
}
