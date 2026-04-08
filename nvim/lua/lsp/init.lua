local M = {}

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

local function on_attach(client, bufnr)
  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
  end

  map("n", "gd", "<cmd>Telescope lsp_definitions<cr>", "Goto Definition")
  map("n", "gr", "<cmd>Telescope lsp_references<cr>", "Goto References")
  map("n", "gi", "<cmd>Telescope lsp_implementations<cr>", "Goto Implementation")
  map("n", "gt", "<cmd>Telescope lsp_type_definitions<cr>", "Goto Type Definition")

  map("n", "K", vim.lsp.buf.hover, "Hover")
  map("n", "<leader>ds", "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols")
  map("n", "<leader>ws", "<cmd>Telescope lsp_workspace_symbols<cr>", "Workspace Symbols")

  map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
  map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
  map("n", "<leader>lf", function()
    vim.lsp.buf.format({ async = true })
  end, "Format with LSP")

  map("n", "[d", vim.diagnostic.goto_prev, "Prev Diagnostic")
  map("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")

  if client.supports_method("textDocument/inlayHint") then
    vim.lsp.inlay_hint.enable(bufnr, true)
  end
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
local cmp_nvim_lsp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if cmp_nvim_lsp_ok then
  capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end

M.on_attach = on_attach
M.capabilities = capabilities

return M

