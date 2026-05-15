-- ============================================================================
-- PLUGINS / LSP  —  servers · efm · diagnostics
-- ============================================================================

-- LSP, Formatting, Linting & Completion
local diagnostic_signs = {
	Error = " ",
	Warn = " ",
	Hint = "",
	Info = "",
}

-- Configure the diagnostic handler
vim.diagnostic.config({
	severity_sort = true,
	float = { border = "rounded", source = "always" },
}, vim.api.nvim_get_runtime_file("plugin/lsp_config.lua", false)[1]) -- hook into lsp

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

-- Create a filter to hide "top-level" errors in Markdown code blocks
local function filter_markdown_diagnostics(diagnostic)
	-- Error codes/messages to ignore in snippets
	local ignored_messages = {
		"Expected unqualified-id", -- Statement outside function
		"A type specifier is required", -- Calling a function like sort() at top level
		"Unknown type name", -- Happens with cout/cin sometimes
	}

	for _, msg in ipairs(ignored_messages) do
		if diagnostic.message:find(msg) then
			return false
		end
	end
	return true
end

function Lsp_on_attach(ev)
	local client = vim.lsp.get_client_by_id(ev.data.client_id)
	if not client then
		return
	end

	local bufnr = ev.buf
	local opts = { noremap = true, silent = true, buffer = bufnr }

	-- Organise imports + format (only if server supports it)
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

	-- Inlay hints
	if client:supports_method("textDocument/inlayHint") then
		if vim.bo[bufnr].buftype == "" then
			vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
		end
	end

	-- clangd otter diagnostic filter for markdown embedded C/C++
	if client.name == "clangd" then
		local ft = vim.bo[bufnr].filetype
		if (ft == "c" or ft == "cpp") and vim.b[bufnr].otter_main_buf then
			local ignored = {
				"Expected unqualified-id",
				"A type specifier is required",
				"Unknown type name",
			}
			local function filter(d)
				for _, msg in ipairs(ignored) do
					if d.message:find(msg) then
						return false
					end
				end
				return true
			end
			vim.diagnostic.config({
				virtual_text = { filter = filter },
				underline = { filter = filter },
				signs = { filter = filter },
			}, bufnr)
		end
	end
end

function Apply_otter_filter(args)
	local client = vim.lsp.get_client_by_id(args.data.client_id)
	if not client or client.name ~= "clangd" then
		return
	end

	local bufnr = args.buf
	local ft = vim.bo[bufnr].filetype

	local allowed = { c = true, cpp = true }

	if allowed[ft] and vim.b[bufnr].otter_main_buf then
		vim.diagnostic.config({
			virtual_text = { filter = filter_markdown_diagnostics },
			underline = { filter = filter_markdown_diagnostics },
			signs = { filter = filter_markdown_diagnostics },
		}, bufnr)
	end
end

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
				c = { clangfmt },
				cpp = { clangfmt },
				go = { gofumpt, go_revive },
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

vim.keymap.set("n", "<leader>gd", function()
	require("fzf-lua").lsp_definitions({ jump_to_single_result = true })
end, opts)

vim.keymap.set("n", "<leader>gD", vim.lsp.buf.definition, opts)

vim.keymap.set("n", "<leader>gS", function()
	vim.cmd("vsplit")
	vim.lsp.buf.definition()
end, opts)

vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

vim.keymap.set("n", "<leader>D", function()
	vim.diagnostic.open_float({ scope = "line" })
end, opts)
vim.keymap.set("n", "<leader>d", function()
	vim.diagnostic.open_float({ scope = "cursor" })
end, opts)
vim.keymap.set("n", "<leader>nd", function()
	vim.diagnostic.jump({ count = 1 })
end, opts)

vim.keymap.set("n", "<leader>pd", function()
	vim.diagnostic.jump({ count = -1 })
end, opts)

vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

vim.keymap.set("n", "<leader>fd", function()
	require("fzf-lua").lsp_definitions({ jump_to_single_result = true })
end, opts)
vim.keymap.set("n", "<leader>fr", function()
	require("fzf-lua").lsp_references()
end, opts)
vim.keymap.set("n", "<leader>ft", function()
	require("fzf-lua").lsp_typedefs()
end, opts)
vim.keymap.set("n", "<leader>fs", function()
	require("fzf-lua").lsp_document_symbols()
end, opts)
vim.keymap.set("n", "<leader>fw", function()
	require("fzf-lua").lsp_workspace_symbols()
end, opts)
vim.keymap.set("n", "<leader>fi", function()
	require("fzf-lua").lsp_implementations()
end, opts)

vim.keymap.set("n", "<leader>q", function()
	vim.diagnostic.setloclist({ open = true })
end, { desc = "Open diagnostic list" })
vim.keymap.set("n", "<leader>dl", vim.diagnostic.open_float, { desc = "Show line diagnostics" })
