local M = {}

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- Set global capabilities for ALL servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
if ok then
  capabilities = cmp_lsp.default_capabilities(capabilities)
end

vim.lsp.config('*', {
  capabilities = capabilities,
})

vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    for _, client in pairs(vim.lsp.get_clients()) do
      for buf in pairs(client.attached_buffers) do
        vim.api.nvim_exec_autocmds("LspAttach", {
          buffer = buf,
          data = { client_id = client.id },
        })
      end
    end
  end,
})

-- Keymaps on attach (autocmd is the correct modern approach)
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end
    map("n", "gd", "<cmd>Telescope lsp_definitions<cr>", "Goto Definition")
    map("n", "gr", "<cmd>Telescope lsp_references<cr>", "Goto References")
    map("n", "gi", "<cmd>Telescope lsp_implementations<cr>", "Goto Implementation")
    map("n", "gt", "<cmd>Telescope lsp_type_definitions<cr>", "Goto Type Definition")
    map("n", "K",  vim.lsp.buf.hover, "Hover")
    map("n", "<leader>ds", "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols")
    map("n", "<leader>ws", "<cmd>Telescope lsp_workspace_symbols<cr>", "Workspace Symbols")
    map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
    map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
    map("n", "<leader>lf", function() vim.lsp.buf.format({ async = true }) end, "Format")
    map("n", "[d", vim.diagnostic.goto_prev, "Prev Diagnostic")
    map("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")

    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end
  end,
})

return M

