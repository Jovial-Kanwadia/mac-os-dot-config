vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.cmd.colorscheme("habamax")
vim.opt.termguicolors = true

require("core.options")
require("core.statusline")
require("core.autocmds")
require("plugins")
require("keymaps")
