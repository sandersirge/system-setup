return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local conform = require("conform")

    conform.setup({
      formatters_by_ft = {
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        svelte = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        graphql = { "prettier" },
        liquid = { "prettier" },
        lua = { "stylua" },
        python = { "isort", "black" },
        -- added: C/C++ (clang-format from Mason), Rust (rustfmt from rustup);
        -- Java has no entry -> LSP fallback formats with jdtls
        c = { "clang-format" },
        cpp = { "clang-format" },
        rust = { "rustfmt" },
      },
      formatters = {
        -- Windows: conform passes the line ending as `--line-ending "\r\n"`; through Mason's isort.cmd
        -- wrapper cmd.exe turns that into an empty argument and isort fails. Without the flag isort keeps
        -- the file's existing line endings.
        isort = vim.fn.has("win32") == 1 and { args = { "--stdout", "--filename", "$FILENAME", "-" } } or nil,
      },
      format_on_save = {
        lsp_format = "fallback", -- Josean's `lsp_fallback = true` (renamed option in conform.nvim)
        async = false,
        timeout_ms = 3000,
      },
    })

    vim.keymap.set({ "n", "v" }, "<leader>mp", function()
      conform.format({
        lsp_format = "fallback",
        async = false,
        timeout_ms = 1000,
      })
    end, { desc = "Format file or range (in visual mode)" })
  end,
}
