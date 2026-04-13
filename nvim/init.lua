vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.clipboard = "unnamedplus"
vim.keymap.set("v", "y", '"+y', { desc = "Yank to system clipboard" })

require("config.lazy")
require("keymaps")
require("lsp.servers")

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99

vim.opt.number = true
vim.opt.relativenumber = true

vim.api.nvim_create_autocmd("InsertEnter", {
  callback = function()
    vim.opt.relativenumber = false
  end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
  callback = function()
    vim.opt.relativenumber = true
  end,
})

-- Auto-enter insert mode when opening a terminal
vim.api.nvim_create_autocmd("TermOpen", {
    group = vim.api.nvim_create_augroup("custom-term-open", { clear = true }),
    callback = function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.cmd("startinsert")
    end,
})

vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

vim.opt.timeoutlen = 400

vim.opt.signcolumn = "yes"

vim.opt.cursorline = true
vim.opt.updatetime = 200
vim.opt.termguicolors = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.conceallevel = 2

vim.opt.termguicolors = true
