-- Treesitter parsers to install (used by plugins/treesitter.lua and scripts/nvim/bootstrap.lua)
return {
  -- Josean's list
  "json", "javascript", "typescript", "tsx", "yaml", "html", "css", "prisma", "markdown",
  "markdown_inline", "svelte", "graphql", "bash", "lua", "vim", "dockerfile", "gitignore",
  "query", "vimdoc", "c",
  -- added for the languages set up in Mason (Java, C/C++, Rust, Python) + common config formats
  "java", "cpp", "rust", "python", "toml", "regex",
}
