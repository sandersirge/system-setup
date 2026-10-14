-- Headless first-run installer for the Neovim config (Windows and WSL):
--   nvim --headless "+Lazy! sync" "+qa!"                         (session 1: plugins)
--   nvim --headless -c "luafile scripts/nvim/bootstrap.lua"       (session 2: parsers + Mason, quits itself)
-- Installs every treesitter parser from lua/sander/parsers.lua and every Mason package named in the
-- mason-lspconfig / mason-tool-installer specs, waits for them, prints a summary and quits.
local results = {}
local function say(s) table.insert(results, s); print(s) end

-- 1. treesitter parsers
local ok_ts, ts = pcall(require, "nvim-treesitter")
if ok_ts then
  local parsers = require("sander.parsers")
  local t0 = vim.uv.hrtime()
  ts.install(parsers):wait(1800000)
  local have = ts.get_installed("parsers")
  local missing = vim.tbl_filter(function(p) return not vim.tbl_contains(have, p) end, parsers)
  say(string.format("treesitter parsers: %d/%d installed (%.0fs)%s", #parsers - #missing, #parsers,
    (vim.uv.hrtime() - t0) / 1e9, #missing > 0 and (" MISSING: " .. table.concat(missing, " ")) or ""))
else
  say("treesitter: nvim-treesitter not loaded (run the Lazy sync first)")
end

-- 2. Mason packages, taken from the plugin specs (no second list to keep in sync)
require("lazy").load({ plugins = { "mason.nvim", "mason-lspconfig.nvim", "mason-tool-installer.nvim" } })
local Plugin = require("lazy.core.plugin")
local cfg = require("lazy.core.config").plugins
local servers = Plugin.values(cfg["mason-lspconfig.nvim"], "opts", false).ensure_installed or {}
local tools = Plugin.values(cfg["mason-tool-installer.nvim"], "opts", false).ensure_installed or {}
local to_pkg = require("mason-lspconfig").get_mappings().lspconfig_to_package
local pkgs = {}
for _, s in ipairs(servers) do table.insert(pkgs, to_pkg[s] or s) end
for _, t in ipairs(tools) do table.insert(pkgs, type(t) == "table" and t[1] or t) end

local registry = require("mason-registry")
local refreshed = false
registry.refresh(function() refreshed = true end)
vim.wait(120000, function() return refreshed end, 200)
local t0 = vim.uv.hrtime()
for _, name in ipairs(pkgs) do
  local ok, pkg = pcall(registry.get_package, name)
  if ok and not pkg:is_installed() and not pkg:is_installing() then pkg:install() end
end
vim.wait(1800000, function()
  for _, name in ipairs(pkgs) do
    local ok, pkg = pcall(registry.get_package, name)
    if ok and pkg:is_installing() then return false end
  end
  return true
end, 1000)
local failed = {}
for _, name in ipairs(pkgs) do
  local ok, pkg = pcall(registry.get_package, name)
  if not ok or not pkg:is_installed() then table.insert(failed, name) end
end
say(string.format("mason packages: %d/%d installed (%.0fs)%s", #pkgs - #failed, #pkgs,
  (vim.uv.hrtime() - t0) / 1e9, #failed > 0 and (" FAILED: " .. table.concat(failed, " ")) or ""))

-- 3. summary of the rest
local total, not_installed = 0, {}
for name, p in pairs(cfg) do
  total = total + 1
  if not p._.installed then table.insert(not_installed, name) end
end
say(string.format("plugins: %d%s", total, #not_installed > 0 and (" NOT INSTALLED: " .. table.concat(not_installed, " ")) or " (all installed)"))
say("rust-analyzer on PATH: " .. tostring(vim.fn.executable("rust-analyzer") == 1)
  .. " | clipboard provider: " .. tostring(vim.fn["provider#clipboard#Executable"]()))
vim.cmd("qa!")
