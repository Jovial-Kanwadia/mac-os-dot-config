
return {
  { "williamboman/mason.nvim", config = true },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",  -- ← ADD THIS
    },
    opts = {
      ensure_installed = {
        "html", "cssls", "tailwindcss", "eslint", "ts_ls",
        "lua_ls", "pyright", "bashls", "gopls", "rust_analyzer",
        "clangd", "jsonls", "yamlls", "dockerls", "marksman", "sqlls",
      },
    },
  },
}

