local gh = function(repo)
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
	{ src = "https://github.com/ThePrimeagen/harpoon", branch = "harpoon2" },
	gh("nvim-lua/plenary.nvim"),
	{ src = gh("mbbill/undotree"), load = true },
	gh("christoomey/vim-tmux-navigator"),
	gh("sindrets/diffview.nvim"),
})

-- ============================================================================
-- PLUGIN CONFIGURATIONS
-- ============================================================================

-- oil
require("oil").setup({
	view_options = {
		show_hidden = true,
	},
})

-- nvim-tmux-navigator
vim.g.tmux_navigator_no_mappings = 1

-- harpoon
local harpoon = require("harpoon")
harpoon.setup()

-- Diffview
vim.opt.fillchars = {
	eob = " ",
	fold = " ",
	foldopen = "▾",
	foldsep = " ",
	diff = "╱",
}

require("diffview").setup({
	enhanced_diff_hl = true,
	view = {
		default = { layout = "diff2_horizontal", disable_diagnostics = true },
		merge_tool = { layout = "diff3_mixed", disable_diagnostics = true },
	},
	hooks = {
		diff_buf_read = function()
			vim.opt_local.wrap = false
			vim.opt_local.list = false
			vim.opt_local.relativenumber = false
			vim.opt_local.colorcolumn = ""
			vim.opt_local.signcolumn = "no"
			vim.opt_local.foldcolumn = "0"
			vim.opt_local.fillchars = {
				diff = "╱",
				fold = " ",
				eob = " ",
			}
			vim.opt_local.diffopt = "filler,context:4,algorithm:histogram,indent-heuristic,linematch:60"
		end,

		view_opened = function(view)
			for _, win in ipairs(view.cur_layout:windows()) do
				local wo = vim.wo[win.handle]
				wo.list = false
				wo.relativenumber = false
				wo.signcolumn = "no"
				wo.foldcolumn = "0"
				wo.colorcolumn = ""
			end
		end,
	},
})

-- Treesitter
local setup_treesitter = function()
	local treesitter = require("nvim-treesitter")
	local ensure_installed = {
		"vim",
		"vimdoc",
		"rust",
		"c",
		"cpp",
		"go",
		"html",
		"css",
		"javascript",
		"json",
		"lua",
		"markdown",
		"python",
		"typescript",
		"vue",
		"svelte",
		"bash",
	}

	local config = require("nvim-treesitter.config")

	local already_installed = config.get_installed()
	local parsers_to_install = {}

	for _, parser in ipairs(ensure_installed) do
		if not vim.tbl_contains(already_installed, parser) then
			table.insert(parsers_to_install, parser)
		end
	end

	if #parsers_to_install > 0 then
		treesitter.install(parsers_to_install)
	end

	local group = vim.api.nvim_create_augroup("TreeSitterConfig", { clear = true })
	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		callback = function(args)
			if vim.list_contains(treesitter.get_installed(), vim.treesitter.language.get_lang(args.match)) then
				vim.treesitter.start(args.buf)
			end
		end,
	})
end
setup_treesitter()

-- fzf-lua
require("fzf-lua").setup({})

-- Gitsigns
require("gitsigns").setup({
	signs = {
		add = { text = "\u{2590}" }, -- ▏
		change = { text = "\u{2590}" }, -- ▐
		delete = { text = "\u{2590}" }, -- ◦
		topdelete = { text = "\u{25e6}" }, -- ◦
		changedelete = { text = "\u{25cf}" }, -- ●
		untracked = { text = "\u{25cb}" }, -- ○
	},
	signcolumn = true,
	current_line_blame = false,
})

-- Mason
require("mason").setup({})

-- Mini Modules
require("mini.ai").setup({})
require("mini.comment").setup({})
require("mini.move").setup({})
require("mini.surround").setup({})
require("mini.cursorword").setup({})
require("mini.indentscope").setup({})
require("mini.pairs").setup({})
require("mini.trailspace").setup({})
require("mini.bufremove").setup({})
require("mini.notify").setup({})
require("mini.icons").setup({})

--require("image").setup({ backend = "kitty",
--	kitty_method = "unicode_placeholders",
--	processor_thread_count = 4,
--	editor_only_render_when_focused = true,
--	tmux_passthrough = true,
--	window_overlap_clear_enabled = true,
--	window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "fzf" },
--	max_width = 100,
--	max_height = 20,
--	integrations = {
--		markdown = {
--			enabled = true,
--			clear_in_insert_mode = false,
--			download_remote_images = false,
--			filetypes = { "markdown", "vimwiki" },
--		},
--	},
--})

require("image").setup({
	backend = "kitty",
	editor_only_render_when_focused = true,
	kitty_method = "unicode_placeholders", -- most stable method inside tmux
	tmux_passthrough = true, -- keep if you use tmux; harmless otherwise
	max_width = 80,
	max_height = 16,
	integrations = {
		markdown = {
			enabled = true,
			clear_in_insert_mode = true, -- cleanly hide while typing, re-show on <Esc>
			download_remote_images = false,
			only_render_image_at_cursor = false,
			only_render_image_at_cursor_mode = "inline", -- "popup" is the alternative
			filetypes = { "markdown", "vimwiki" },
		},
	},
})

require("img-clip").setup({
	default = {
		dir_path = "attachments",
		relative_to_current_file = true, -- dir_path is resolved next to the open file
		use_absolute_path = false, -- insert a relative path into the buffer
		extension = "png",
		file_name = "%Y%m%d-%H%M%S", -- e.g. 20250426-143022.png
		template = "![$CURSOR]($FILE_PATH)",
		prompt_for_file_name = false, -- no interactive prompt; just paste
		insert_mode_after_paste = false, -- stay in normal mode after pasting
		post_paste_cmd = function()
			local ok, image = pcall(require, "image")
			if ok then
				vim.defer_fn(function()
					image.clear() -- clear stale placements
					vim.cmd("doautocmd CursorMoved")
				end, 50)
			end
		end,
	},
	filetypes = {
		markdown = {
			-- Override dir_path per-filetype if you want a different folder name
			dir_path = "attachments",
		},
	},
})

require("render-markdown").setup({
	render_modes = { "n", "c", "t" },
	heading = {
		enabled = true,
		sign = false,
	},
	debounce = 100,
})

-- LSP, Formatting, Linting & Completion
local diagnostic_signs = {
	Error = " ",
	Warn = " ",
	Hint = "",
	Info = "",
}

vim.diagnostic.config({
	virtual_text = { prefix = "●", spacing = 4 },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = diagnostic_signs.Error,
			[vim.diagnostic.severity.WARN] = diagnostic_signs.Warn,
			[vim.diagnostic.severity.INFO] = diagnostic_signs.Info,
			[vim.diagnostic.severity.HINT] = diagnostic_signs.Hint,
		},
	},
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		border = "rounded",
		source = "always",
		header = "",
		prefix = "",
		focusable = false,
		style = "minimal",
	},
})

local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
	opts = opts or {}
	opts.border = opts.border or "rounded"
	return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

local function lsp_on_attach(ev)
	local client = vim.lsp.get_client_by_id(ev.data.client_id)
	if not client then
		return
	end

	local bufnr = ev.buf
	local opts = { noremap = true, silent = true, buffer = bufnr }

	if client:supports_method("textDocument/codeAction", bufnr) then
		vim.keymap.set("n", "<leader>oi", function()
			vim.lsp.buf.code_action({
				context = { only = { "source.organizeImports" }, diagnostics = {} },
				apply = true,
				bufnr = bufnr,
			})
			vim.defer_fn(function()
				vim.lsp.buf.format({ bufnr = bufnr })
			end, 50)
		end, opts)
	end
	if client:supports_method("textDocument/inlayHint") then
		vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
	end
end

vim.api.nvim_create_autocmd("LspAttach", { group = augroup, callback = lsp_on_attach })

require("blink.cmp").setup({
	keymap = {
		preset = "none",
		["<C-Space>"] = { "show", "hide" },
		["<CR>"] = { "accept", "fallback" },
		["<C-j>"] = { "select_next", "fallback" },
		["<C-k>"] = { "select_prev", "fallback" },
		["<Tab>"] = { "snippet_forward", "fallback" },
		["<S-Tab>"] = { "snippet_backward", "fallback" },
	},
	appearance = { nerd_font_variant = "mono" },
	completion = { menu = { auto_show = true } },
	sources = { default = { "lsp", "path", "buffer", "snippets" } },
	snippets = {
		expand = function(snippet)
			require("luasnip").lsp_expand(snippet)
		end,
	},

	fuzzy = {
		implementation = "prefer_rust",
	},
})

vim.lsp.config["*"] = {
	capabilities = require("blink.cmp").get_lsp_capabilities(),
}

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			diagnostics = { globals = { "vim", "augroup", "opts" } },
			telemetry = { enable = false },
		},
	},
})
vim.lsp.config("pyright", {})
vim.lsp.config("bashls", {
	filetypes = { "sh", "bash" },
	settings = {
		bashIde = {
			globPattern = "*@(.sh|.inc|.bash|.command)",
		},
	},
})
vim.lsp.config("ts_ls", {})
vim.lsp.config("gopls", {})
vim.lsp.config("clangd", {
	cmd = {
		"clangd",
		"--background-index",
		"--clang-tidy",
		"--header-insertion=never",
		"--completion-style=detailed",
		"--fallback-style=Google",
	},
	capabilities = { offsetEncoding = { "utf-8" } },
})

do
	local luacheck = require("efmls-configs.linters.luacheck")
	local stylua = require("efmls-configs.formatters.stylua")

	local flake8 = require("efmls-configs.linters.flake8")
	local black = require("efmls-configs.formatters.black")

	local prettier_d = require("efmls-configs.formatters.prettier_d")
	local eslint_d = require("efmls-configs.linters.eslint_d")

	local fixjson = require("efmls-configs.formatters.fixjson")

	local shellcheck = require("efmls-configs.linters.shellcheck")
	local shfmt = require("efmls-configs.formatters.shfmt")

	local cpplint = require("efmls-configs.linters.cpplint")
	local clangfmt = require("efmls-configs.formatters.clang_format")

	local go_revive = require("efmls-configs.linters.go_revive")
	local gofumpt = require("efmls-configs.formatters.gofumpt")

	vim.lsp.config("efm", {
		filetypes = {
			"c",
			"cpp",
			"css",
			"go",
			"html",
			"javascript",
			"javascriptreact",
			"json",
			"jsonc",
			"lua",
			"markdown",
			"python",
			"sh",
			"typescript",
			"typescriptreact",
			"vue",
			"svelte",
			"bash",
			"sh",
		},
		init_options = { documentFormatting = true },
		settings = {
			languages = {
				c = { clangfmt, cpplint },
				go = { gofumpt, go_revive },
				cpp = { clangfmt, cpplint },
				css = { prettier_d },
				html = { prettier_d },
				javascript = { eslint_d, prettier_d },
				javascriptreact = { eslint_d, prettier_d },
				json = { eslint_d, fixjson },
				jsonc = { eslint_d, fixjson },
				lua = { luacheck, stylua },
				markdown = { prettier_d },
				python = { flake8, black },
				sh = { shellcheck, shfmt },
				bash = { shellcheck, shfmt },
				typescript = { eslint_d, prettier_d },
				typescriptreact = { eslint_d, prettier_d },
				vue = { eslint_d, prettier_d },
				svelte = { eslint_d, prettier_d },
			},
		},
	})
end

vim.lsp.enable({
	"lua_ls",
	"pyright",
	"bashls",
	"ts_ls",
	"gopls",
	"clangd",
	"efm",
})
