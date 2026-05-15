-- ============================================================================
-- AUTOCMDS
-- ============================================================================
local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

local function set_transparent() -- set UI component to transparent
	local groups = {
		"Normal",
		"NormalNC",
		"EndOfBuffer",
		"NormalFloat",
		"FloatBorder",
		"StatusLine",
		"StatusLineNC",
		"TabLine",
		"TabLineFill",
		"TabLineSel",
	}
	for _, g in ipairs(groups) do
		vim.api.nvim_set_hl(0, g, { bg = "none" })
	end
	vim.api.nvim_set_hl(0, "TabLineFill", { bg = "none", fg = "#767676" })
end

set_transparent()

-- Format on save (ONLY real file buffers, ONLY when efm is attached)
vim.api.nvim_create_autocmd("BufWritePre", {
	group = augroup,
	pattern = {
		"*.lua",
		"*.py",
		"*.go",
		"*.js",
		"*.jsx",
		"*.ts",
		"*.tsx",
		"*.json",
		"*.css",
		"*.scss",
		"*.html",
		"*.sh",
		"*.bash",
		"*.zsh",
		"*.c",
		"*.cpp",
		"*.h",
		"*.hpp",
	},
	callback = function(args)
		-- avoid formatting non-file buffers (helps prevent weird write prompts)
		if vim.bo[args.buf].buftype ~= "" then
			return
		end
		if not vim.bo[args.buf].modifiable then
			return
		end
		if vim.api.nvim_buf_get_name(args.buf) == "" then
			return
		end

		local has_efm = false
		for _, c in ipairs(vim.lsp.get_clients({ bufnr = args.buf })) do
			if c.name == "efm" then
				has_efm = true
				break
			end
		end
		if not has_efm then
			return
		end

		pcall(vim.lsp.buf.format, {
			bufnr = args.buf,
			timeout_ms = 2000,
			filter = function(c)
				return c.name == "efm"
			end,
		})
	end,
})

-- highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup,
	callback = function()
		vim.hl.on_yank()
	end,
})

-- return to last cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup,
	desc = "Restore last cursor position",
	callback = function()
		if vim.o.diff then -- except in diff mode
			return
		end

		local last_pos = vim.api.nvim_buf_get_mark(0, '"') -- {line, col}
		local last_line = vim.api.nvim_buf_line_count(0)

		local row = last_pos[1]
		if row < 1 or row > last_line then
			return
		end

		pcall(vim.api.nvim_win_set_cursor, 0, last_pos)
	end,
})

-- wrap, linebreak and spellcheck on markdown and text files
vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = { "markdown", "text", "gitcommit" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
		vim.opt_local.spell = false
	end,
})

-- re-apply the transparency automatically
vim.api.nvim_create_autocmd("ColorScheme", {
	group = augroup,
	callback = set_transparent,
})

-- if no args to nvim open oil
vim.api.nvim_create_autocmd("VimEnter", {
	group = augroup,
	callback = function()
		-- 1. Check if we started with no file arguments
		if vim.fn.argc() == 0 then
			-- 2. Check if the current buffer is actually empty
			local buf_name = vim.api.nvim_buf_get_name(0)
			if buf_name == "" then
				-- 3. Schedule the edit to avoid race conditions with CWD
				vim.schedule(function()
					vim.cmd("edit .")
				end)
			end
		end
	end,
})

-- undotree config
vim.g.undotree_SplitWidth = 40
vim.g.undotree_SetFocusWhenToggle = 1

-- Auto-activate otter on markdown / mdx files
vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = { "markdown", "mdx", "quarto" },
	callback = function()
		-- Languages to activate LSP for inside code blocks.
		-- Add any language whose LSP you have configured.
		local ok, otter = pcall(require, "otter")
		if not ok then
			return
		end
		otter.activate(
			{ "python", "lua", "bash", "javascript", "typescript", "go", "rust" },
			true, -- completion = true
			true, -- diagnostics = true
			nil -- tsquery = nil (use default)
		)
	end,
})

-- Terminal: hide line numbers / sign column
vim.api.nvim_create_autocmd("TermOpen", {
	group = augroup,
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.signcolumn = "no"
	end,
})

-- Terminal: auto-close buffer when shell exits cleanly
vim.api.nvim_create_autocmd("TermClose", {
	group = augroup,
	callback = function()
		if vim.v.event.status == 0 then
			vim.api.nvim_buf_delete(0, {})
		end
	end,
})

-- Force terminal to recalculate graphics on InsertEnter in markdown
vim.api.nvim_create_autocmd("InsertEnter", {
	group = augroup,
	pattern = { "*.md", "*.markdown" },
	callback = function()
		vim.cmd("redraw!")
	end,
})

vim.api.nvim_create_autocmd("LspAttach", {
	group = augroup,
	callback = function(args)
		Lsp_on_attach(args)
		Apply_otter_filter(args)
	end,
})
