-- nvim-treesitter `main` branch (the maintained rewrite for Neovim 0.12).
-- Josean's repo pins the old `master` branch (require("nvim-treesitter.configs")); this is the same
-- setup ported to the new API. Needs the tree-sitter CLI (>= 0.26.1) and a C compiler to build parsers.
local parsers = {
  -- Josean's list
  "json", "javascript", "typescript", "tsx", "yaml", "html", "css", "prisma", "markdown",
  "markdown_inline", "svelte", "graphql", "bash", "lua", "vim", "dockerfile", "gitignore",
  "query", "vimdoc", "c",
  -- added for the languages set up in Mason (Java, C/C++, Rust, Python) + common config formats
  "java", "cpp", "rust", "python", "toml", "regex",
}

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false, -- main branch does not support lazy-loading
  build = ":TSUpdate",
  dependencies = {
    "windwp/nvim-ts-autotag", -- auto close/rename html, jsx, svelte... tags
  },
  config = function()
    -- install missing parsers (async, no-op for parsers that are already installed)
    require("nvim-treesitter").install(parsers)

    -- highlighting (built into Neovim) + indentation (nvim-treesitter) for every buffer with a parser
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("SanderTreesitter", { clear = true }),
      callback = function(ev)
        local lang = vim.treesitter.language.get_lang(ev.match)
        if lang and pcall(vim.treesitter.start, ev.buf, lang) then
          vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })

    -- use bash parser for zsh files
    vim.treesitter.language.register("bash", "zsh")

    -- incremental selection: Josean's keys mapped to Neovim 0.12's built-in `an` / `in` (:h v_an)
    local keymap = vim.keymap
    keymap.set("n", "<C-space>", "van", { remap = true, desc = "Start incremental selection (treesitter node)" })
    keymap.set("x", "<C-space>", "an", { remap = true, desc = "Grow selection to parent node" })
    keymap.set("x", "<bs>", "in", { remap = true, desc = "Shrink selection to child node" })

    require("nvim-ts-autotag").setup({})
  end,
}
