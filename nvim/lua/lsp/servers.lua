
local servers = {
  "html", "cssls", "tailwindcss", "eslint", "ts_ls",
  "lua_ls", "pyright", "bashls",
  "gopls", "rust_analyzer", "clangd",
  "jsonls", "yamlls", "dockerls", "marksman", "sqlls",
}

-- lua_ls extra settings (merged, not replaced)
vim.lsp.config("lua_ls", {
  settings = {
    Lua = { diagnostics = { globals = { "vim" } } },
  },
})

for _, server in ipairs(servers) do
  vim.lsp.enable(server)
end

