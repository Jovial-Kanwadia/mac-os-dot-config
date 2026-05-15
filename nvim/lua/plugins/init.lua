local function gh(repo)
	return "https://github.com/" .. repo
end

vim.pack.add({
	gh("nvim-treesitter/nvim-treesitter"),
	gh("stevearc/oil.nvim"),
	gh("ibhagwan/fzf-lua"),
	gh("mason-org/mason.nvim"),
	gh("echasnovski/mini.nvim"),
	gh("lewis6991/gitsigns.nvim"),
	gh("neovim/nvim-lspconfig"),
	gh("creativenull/efmls-configs-nvim"),
	gh("saghen/blink.cmp"),
	gh("saghen/blink.lib"),
	gh("L3MON4D3/LuaSnip"),
	gh("MeanderingProgrammer/render-markdown.nvim"),
	gh("3rd/image.nvim"),
	gh("HakonHarnes/img-clip.nvim"),
	{ src = gh("ThePrimeagen/harpoon"), branch = "harpoon2" },
	gh("nvim-lua/plenary.nvim"),
	{ src = gh("mbbill/undotree"), load = true },
	gh("christoomey/vim-tmux-navigator"),
	gh("sindrets/diffview.nvim"),
	gh("jmbuhr/otter.nvim"),
})

-- Load plugin configurations (order matters for dependencies)
require("plugins.ui") -- oil, mason, mini, image, img-clip, otter
require("plugins.treesitter") -- treesitter
require("plugins.git") -- gitsigns, diffview
require("plugins.editor") -- harpoon, fzf-lua, undotree, tmux
require("plugins.lsp") -- LSP servers + efm + diagnostics
require("plugins.completion") -- blink.cmp + luasnip
require("plugins.terminal") -- floating terminal
require("plugins.cp_runner") -- competitive programming runner
require("plugins.md_runner") -- markdown code-block runner

