return {
  {
    "williamboman/mason.nvim",
    opts = {},
  },
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "html",
        "cssls",
        "tailwindcss",
        "eslint",
        "ts_ls",
        "lua_ls",
        "pyright",
        "bashls",
        "gopls",
        "rust_analyzer",
        "clangd",
        "jsonls",
        "yamlls",
        "dockerls",
        "marksman",
        "sqlls",
      },
    },
  },
}
