return {
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      -- list of servers for mason to install (mason-lspconfig v2 also vim.lsp.enable()s them)
      ensure_installed = {
        -- Josean's list
        "ts_ls",
        "html",
        "cssls",
        "tailwindcss",
        "svelte",
        "lua_ls",
        "graphql",
        "emmet_ls",
        "prismals",
        "pyright",
        "eslint",
        -- added: Java, C/C++ (Rust's rust-analyzer comes from rustup, enabled in sander/lsp.lua)
        "jdtls",
        "clangd",
      },
      -- mason-lspconfig v2 vim.lsp.enable()s every installed package that has an LSP config;
      -- stylua (installed below as a formatter) has one too -> don't run it as a language server,
      -- formatting is done by conform.nvim
      automatic_enable = {
        exclude = { "stylua" },
      },
    },
    dependencies = {
      {
        "williamboman/mason.nvim",
        opts = {
          ui = {
            icons = {
              package_installed = "✓",
              package_pending = "➜",
              package_uninstalled = "✗",
            },
          },
        },
      },
      "neovim/nvim-lspconfig",
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        "prettier", -- prettier formatter
        "stylua", -- lua formatter
        "isort", -- python formatter
        "black", -- python formatter
        "pylint",
        "eslint_d",
        "clang-format", -- added: C/C++ formatter (Rust uses rustfmt from rustup)
      },
    },
    dependencies = {
      "williamboman/mason.nvim",
    },
  },
}
