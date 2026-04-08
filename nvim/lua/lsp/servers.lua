local lsp = require("lsp")

local servers = {
  -- Web
  "html",
  "cssls",
  "tailwindcss",
  "eslint",
  "ts_ls",

  -- Backend / scripting
  "lua_ls",
  "pyright",
  "bashls",

  -- Systems
  "gopls",
  "rust_analyzer",
  "clangd",

  -- Config / DevOps
  "jsonls",
  "yamlls",
  "dockerls",
  "marksman",

  -- Database
  "sqlls",
}


for _, server in ipairs(servers) do
  vim.lsp.config(server, {
    on_attach = lsp.on_attach,
    capabilities = lsp.capabilities,
  })
  vim.lsp.enable(server)
end

-- Extra config example for lua_ls
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
    },
  },
})

