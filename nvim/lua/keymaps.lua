vim.g.mapleader = " " -- space for leader
vim.g.maplocalleader = " " -- space for localleader

-- better movement in wrapped text
vim.keymap.set("n", "j", function()
	return vim.v.count == 0 and "gj" or "j"
end, { expr = true, silent = true, desc = "Down (wrap-aware)" })
vim.keymap.set("n", "k", function()
	return vim.v.count == 0 and "gk" or "k"
end, { expr = true, silent = true, desc = "Up (wrap-aware)" })

vim.keymap.set("n", "<leader>c", ":nohlsearch<CR>", { desc = "Clear search highlights" })

vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

vim.keymap.set("x", "<leader>p", '"_dP', { desc = "Paste without yanking" })
vim.keymap.set({ "n", "v" }, "<leader>x", '"_d', { desc = "Delete without yanking" })

vim.keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })

vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

vim.keymap.set("n", "<leader>sv", ":vsplit<CR>", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>sh", ":split<CR>", { desc = "Split window horizontally" })
vim.keymap.set("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })

vim.keymap.set("n", "<leader>pa", function() -- show file path
	local path = vim.fn.expand("%:p")
	vim.fn.setreg("+", path)
	print("file:", path)
end, { desc = "Copy full file path" })

vim.keymap.set("n", "<leader>td", function()
	vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle diagnostics" })

vim.keymap.set("n", "<CR>", function()
	local row = vim.api.nvim_win_get_cursor(0)[1]
	vim.api.nvim_buf_set_lines(0, row, row, false, { "" })
	vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
end, { desc = "Add new line below" })

vim.keymap.set("n", "<S-CR>", function()
	local row = vim.api.nvim_win_get_cursor(0)[1]
	vim.api.nvim_buf_set_lines(0, row, row, false, { "" })
end, { desc = "Add new line below (stay on current line)" })

vim.keymap.set("n", "<BS>", '"_dd', { desc = "Delete line without yanking" })

-- oil
vim.keymap.set("n", "-", function()
	require("oil").open()
end, { desc = "Open Parent Directory" })

-- fzf
vim.keymap.set("n", "<leader>ff", function()
	require("fzf-lua").files()
end, { desc = "FZF Files" })
vim.keymap.set("n", "<leader>fg", function()
	require("fzf-lua").live_grep()
end, { desc = "FZF Live Grep" })
vim.keymap.set("n", "<leader>fb", function()
	require("fzf-lua").buffers()
end, { desc = "FZF Buffers" })
vim.keymap.set("n", "<leader>fh", function()
	require("fzf-lua").help_tags()
end, { desc = "FZF Help Tags" })
vim.keymap.set("n", "<leader>fx", function()
	require("fzf-lua").diagnostics_document()
end, { desc = "FZF Diagnostics Document" })
vim.keymap.set("n", "<leader>fX", function()
	require("fzf-lua").diagnostics_workspace()
end, { desc = "FZF Diagnostics Workspace" })

-- gitsigns
vim.keymap.set("n", "]h", function()
	require("gitsigns").next_hunk()
end, { desc = "Next git hunk" })
vim.keymap.set("n", "[h", function()
	require("gitsigns").prev_hunk()
end, { desc = "Previous git hunk" })
vim.keymap.set("n", "<leader>hs", function()
	require("gitsigns").stage_hunk()
end, { desc = "Stage hunk" })
vim.keymap.set("n", "<leader>hr", function()
	require("gitsigns").reset_hunk()
end, { desc = "Reset hunk" })
vim.keymap.set("n", "<leader>hp", function()
	require("gitsigns").preview_hunk()
end, { desc = "Preview hunk" })
vim.keymap.set("n", "<leader>hb", function()
	require("gitsigns").blame_line({ full = true })
end, { desc = "Blame line" })
vim.keymap.set("n", "<leader>hB", function()
	require("gitsigns").toggle_current_line_blame()
end, { desc = "Toggle inline blame" })
vim.keymap.set("n", "<leader>hd", function()
	require("gitsigns").diffthis()
end, { desc = "Diff this" })

-- LSP
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

vim.api.nvim_create_autocmd("TermClose", {
	group = augroup,
	callback = function()
		if vim.v.event.status == 0 then
			vim.api.nvim_buf_delete(0, {})
		end
	end,
})

vim.api.nvim_create_autocmd("TermOpen", {
	group = augroup,
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.signcolumn = "no"
	end,
})

-- ============================================================================
-- FLOATING TERMINAL
-- ============================================================================

local term = { buf = nil, win = nil }

local function term_buf_valid()
	if not term.buf or not vim.api.nvim_buf_is_valid(term.buf) then
		return false
	end
	-- check the terminal job is still alive
	local ok, chan = pcall(vim.api.nvim_buf_get_var, term.buf, "terminal_job_id")
	return ok and chan and vim.fn.jobwait({ chan }, 0)[1] == -1
end

local function term_win_valid()
	return term.win and vim.api.nvim_win_is_valid(term.win)
end

local function term_open_win()
	local width = math.floor(vim.o.columns * 0.85)
	local height = math.floor(vim.o.lines * 0.85)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	term.win = vim.api.nvim_open_win(term.buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
		title = "Terminal ",
		title_pos = "center",
		zindex = 50,
	})

	vim.wo[term.win].winblend = 0
	vim.wo[term.win].winhighlight = "Normal:FloatTermNormal,FloatBorder:FloatTermBorder"
	vim.api.nvim_set_hl(0, "FloatTermNormal", { bg = "none" })
	vim.api.nvim_set_hl(0, "FloatTermBorder", { bg = "none" })
end

local term_augroup = vim.api.nvim_create_augroup("FloatTerm", { clear = true })

local function FloatingTerminal()
	-- toggle: close if already visible
	if term_win_valid() then
		vim.api.nvim_win_close(term.win, false)
		term.win = nil
		return
	end

	-- wipe dead buffer so we get a fresh shell
	if not term_buf_valid() then
		if term.buf and vim.api.nvim_buf_is_valid(term.buf) then
			pcall(vim.api.nvim_buf_delete, term.buf, { force = true })
		end
		term.buf = nil
	end

	-- create buffer once
	if not term.buf then
		term.buf = vim.api.nvim_create_buf(false, true)
		vim.bo[term.buf].bufhidden = "hide"

		-- clear the augroup and set a single persistent WinClosed watcher
		vim.api.nvim_clear_autocmds({ group = term_augroup })
		vim.api.nvim_create_autocmd("WinClosed", {
			group = term_augroup,
			callback = function(ev)
				if term.win and tonumber(ev.match) == term.win then
					term.win = nil
				end
			end,
		})
	end

	term_open_win()

	-- start shell only if no live job exists yet
	if not term_buf_valid() then
		vim.fn.termopen(vim.o.shell, {
			on_exit = function()
				vim.schedule(function()
					if term.buf and vim.api.nvim_buf_is_valid(term.buf) then
						pcall(vim.api.nvim_buf_delete, term.buf, { force = true })
					end
					term.buf = nil
					term.win = nil
				end)
			end,
		})
	end

	vim.cmd("startinsert")
end

vim.keymap.set("n", "<leader>t", FloatingTerminal, {
	noremap = true,
	silent = true,
	desc = "Toggle floating terminal",
})

-- <Esc> → normal mode inside terminal (so vim motions work)
-- use <C-t> to close without killing the shell
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], {
	noremap = true,
	silent = true,
	desc = "Terminal: enter normal mode",
})
vim.keymap.set("t", "<C-t>", function()
	if term_win_valid() then
		vim.api.nvim_win_close(term.win, false)
		term.win = nil
	end
end, { noremap = true, silent = true, desc = "Terminal: hide window" })

-- re-enter insert when jumping back into the terminal window
vim.api.nvim_create_autocmd("BufEnter", {
	group = term_augroup,
	callback = function()
		if term.buf and vim.api.nvim_get_current_buf() == term.buf then
			vim.cmd("startinsert")
		end
	end,
})
-- ============================================================================
-- Image Keymaps
-- ============================================================================

-- Define your single source of truth for all assets
local global_attachments = vim.fn.expand("~/Programming/attachments")

vim.keymap.set("n", "<leader>pi", function()
	local fzf = require("fzf-lua")
	local path = require("fzf-lua.path")
	local ok_image, image_api = pcall(require, "image")

	local image_previewer = require("fzf-lua.previewer.builtin").base:extend()
	function image_previewer:new(o, opts, fzf_win)
		image_previewer.super.new(self, o, opts, fzf_win)
		self.type = "buffer"
		return self
	end

	function image_previewer:populate_previewbuf(entry)
		local tmpbuf = self:get_previewbuf()
		local entry_path = path.entry_to_file(entry, self.opts).path
		-- Strictly use the global path
		local filepath = global_attachments .. "/" .. entry_path

		if ok_image then
			image_api.clear()
		end
		vim.api.nvim_buf_set_lines(tmpbuf, 0, -1, false, { "Viewing: " .. entry_path })

		vim.schedule(function()
			if ok_image then
				image_api
					.from_file(filepath, {
						window = self.win.preview_winid,
						buffer = tmpbuf,
						with_virtual_padding = true,
					})
					:render()
			end
		end)
	end

	fzf.files({
		cwd = global_attachments,
		prompt = "Insert Image> ",
		previewer = image_previewer,
		actions = {
			["default"] = function(selected)
				local filename = vim.fn.fnamemodify(path.entry_to_file(selected[1]).path, ":t")
				-- Generate the link using the absolute path so it renders perfectly from any markdown file on your system
				local link = string.format("![](%s/%s)", global_attachments, filename)
				vim.api.nvim_put({ link }, "c", true, true)
			end,
		},
	})
end, { desc = "Insert Image (fzf-lua)" })

vim.keymap.set("n", "<leader>pp", function()
	-- Pass the global path directly into img-clip's paste function
	require("img-clip").paste_image({
		dir_path = global_attachments,
		use_absolute_path = true, -- Ensures the generated markdown link points to the absolute path
	})
end, { desc = "Paste image from clipboard" })

vim.api.nvim_create_autocmd("InsertEnter", {
	pattern = { "*.md", "*.markdown" },
	callback = function()
		-- Forces terminal to recalculate graphics clipping without moving viewport
		vim.cmd("redraw!")
	end,
})

-- harpoon
local harpoon = require("harpoon")

harpoon.setup({
	settings = {
		save_on_toggle = true,
		sync_on_ui_close = true,
	},
})

vim.keymap.set("n", "<leader>hh", function()
	harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = "Harpoon Menu" })
vim.keymap.set("n", "<leader>a", function()
	harpoon:list():add()
end)

vim.keymap.set("n", "<leader>hf", function()
	local marks = harpoon:list()
	local file_paths = {}
	-- Extract the paths from Harpoon's internal list
	for _, item in ipairs(marks.items) do
		table.insert(file_paths, item.value)
	end

	require("fzf-lua").fzf_exec(file_paths, {
		prompt = "Harpoon Marks> ",
		actions = {
			["default"] = function(selected)
				vim.cmd("edit " .. selected[1])
			end,
		},
	})
end, { desc = "FZF Harpoon Marks" })

for i = 1, 4 do
	vim.keymap.set("n", "<leader>" .. i, function()
		harpoon:list():select(i)
	end, { desc = "Harpoon jump to " .. i })
end

vim.keymap.set("n", "<leader>hc", function()
	require("harpoon"):list():clear()
	vim.notify("Harpoon list cleared", vim.log.levels.INFO)
end, { desc = "Harpoon: Clear all marks" })

-- undotree
vim.keymap.set("n", "<leader>u", "<cmd>UndotreeToggle<cr>", { desc = "Toggle Undotree" })

-- nvim-tmux-navigator
vim.keymap.set("n", "<C-h>", "<cmd>TmuxNavigateLeft<cr>", { desc = "Window Left" })
vim.keymap.set("n", "<C-j>", "<cmd>TmuxNavigateDown<cr>", { desc = "Window Down" })
vim.keymap.set("n", "<C-k>", "<cmd>TmuxNavigateUp<cr>", { desc = "Window Up" })
vim.keymap.set("n", "<C-l>", "<cmd>TmuxNavigateRight<cr>", { desc = "Window Right" })

-- ============================================================================
-- DIFFVIEW
-- ============================================================================

require("diffview").setup({
	enhanced_diff_hl = true,
	view = {
		default = { layout = "diff2_horizontal" },
		merge_tool = { layout = "diff3_mixed", disable_diagnostics = true },
	},
	hooks = {
		diff_buf_read = function()
			vim.opt_local.wrap = false
			vim.opt_local.list = false
			vim.opt_local.colorcolumn = ""
		end,
	},
})

-- Close every open diffview regardless of which tab you're currently on,
-- then return focus to wherever you were before.
local function diffview_close_all()
	local lib = require("diffview.lib")
	local origin = vim.api.nvim_get_current_tabpage()
	for _, view in ipairs(lib.views) do
		if view.tabpage and vim.api.nvim_tabpage_is_valid(view.tabpage) then
			vim.api.nvim_set_current_tabpage(view.tabpage)
			vim.cmd("DiffviewClose")
		end
	end
	-- return to original tab if it still exists
	if vim.api.nvim_tabpage_is_valid(origin) then
		vim.api.nvim_set_current_tabpage(origin)
	end
end

local function diffview_toggle(cmd)
	local lib = require("diffview.lib")
	if next(lib.views) ~= nil then -- ANY diffview open, anywhere
		diffview_close_all()
	else
		vim.cmd(cmd)
	end
end

vim.keymap.set("n", "<leader>gv", function()
	diffview_toggle("DiffviewOpen")
end, { desc = "Diff: toggle (index vs working tree)" })

vim.keymap.set("n", "<leader>gV", function()
	diffview_toggle("DiffviewOpen HEAD")
end, { desc = "Diff: toggle (HEAD vs working tree)" })

vim.keymap.set("n", "<leader>gH", function()
	diffview_toggle("DiffviewFileHistory %")
end, { desc = "Diff: toggle current file history" })

vim.keymap.set("n", "<leader>gh", function()
	diffview_toggle("DiffviewFileHistory")
end, { desc = "Diff: toggle repo history" })

vim.keymap.set("n", "<leader>gm", function()
	diffview_toggle("DiffviewOpen")
end, { desc = "Diff: toggle merge tool" })

vim.keymap.set("x", "<leader>gh", function()
	-- Capture everything while STILL in visual mode
	-- vim.fn.getpos("v") = visual start, getpos(".") = cursor (end)
	local start_pos = vim.fn.getpos("v") -- {bufnum, lnum, col, off}
	local end_pos = vim.fn.getpos(".")

	local line1 = start_pos[2]
	local line2 = end_pos[2]

	-- normalize so line1 is always the smaller
	if line1 > line2 then
		line1, line2 = line2, line1
	end

	local filepath = vim.fn.expand("%:p")

	-- Validate: must be a real saved file
	if filepath == "" then
		vim.notify("DiffviewFileHistory: buffer has no file path", vim.log.levels.WARN)
		return
	end
	if vim.bo.modified then
		vim.notify("DiffviewFileHistory: save the file first (range history uses git)", vim.log.levels.WARN)
		return
	end

	-- Validate: file must be tracked by git
	local git_root = vim.fn.systemlist(
		"git -C " .. vim.fn.shellescape(vim.fn.fnamemodify(filepath, ":h")) .. " rev-parse --show-toplevel 2>/dev/null"
	)
	if vim.v.shell_error ~= 0 or #git_root == 0 then
		vim.notify("DiffviewFileHistory: file is not inside a git repository", vim.log.levels.WARN)
		return
	end

	local _ = vim.fn.system(
		"git -C "
			.. vim.fn.shellescape(git_root[1])
			.. " ls-files --error-unmatch "
			.. vim.fn.shellescape(filepath)
			.. " 2>&1"
	)
	if vim.v.shell_error ~= 0 then
		vim.notify("DiffviewFileHistory: file is not tracked by git", vim.log.levels.WARN)
		return
	end

	local lib = require("diffview.lib")

	-- Exit visual mode first, then schedule the command so neovim
	-- has fully processed the mode change before we open diffview.
	local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
	vim.api.nvim_feedkeys(esc, "nx", false)

	vim.schedule(function()
		if next(lib.views) ~= nil then
			diffview_close_all()
		else
			-- Pass the range as an Ex range prefix — this is what diffview
			-- uses internally to build git log's -L flag.
			vim.cmd(line1 .. "," .. line2 .. "DiffviewFileHistory --follow " .. vim.fn.fnameescape(filepath))
		end
	end)
end, { desc = "Diff: toggle range history" })

-- Run CP script on the current file
vim.keymap.set("n", "<leader>rr", function()
	vim.cmd("write") -- Always save before running
	-- We use the full path to be safe and 'split' to keep the output visible
	vim.cmd("split | term cpr -r " .. vim.fn.expand("%"))
end, { desc = "CP: Save and Run" })

-- ============================================================================
-- COMPETITIVE PROGRAMMING RUNNER
-- ============================================================================

local CP_HEADER = vim.fn.expand("~/.config/cp/include")
local TLE_SECS = 2

-- ─── Output window state ────────────────────────────────────────────
local cp_runner = { buf = nil, win = nil, job = nil }

local function cp_win_open()
	-- reuse existing buffer or create fresh
	if not cp_runner.buf or not vim.api.nvim_buf_is_valid(cp_runner.buf) then
		cp_runner.buf = vim.api.nvim_create_buf(false, true)
		vim.bo[cp_runner.buf].filetype = "cp_output"
		vim.bo[cp_runner.buf].bufhidden = "hide"
		vim.bo[cp_runner.buf].swapfile = false
		vim.bo[cp_runner.buf].buflisted = false
	end

	local W = math.floor(vim.o.columns * 0.45)
	local H = math.floor(vim.o.lines * 0.80)
	local row = math.floor((vim.o.lines - H) / 2)
	local col = math.floor((vim.o.columns - W) / 2) + math.floor(vim.o.columns * 0.05)

	if cp_runner.win and vim.api.nvim_win_is_valid(cp_runner.win) then
		-- resize in place when already open
		vim.api.nvim_win_set_config(cp_runner.win, {
			relative = "editor",
			width = W,
			height = H,
			row = row,
			col = col,
		})
	else
		cp_runner.win = vim.api.nvim_open_win(cp_runner.buf, true, {
			relative = "editor",
			width = W,
			height = H,
			row = row,
			col = col,
			style = "minimal",
			border = "rounded",
			title = " ⚡ CP Runner ",
			title_pos = "center",
			zindex = 60,
		})
		vim.wo[cp_runner.win].wrap = false
		vim.wo[cp_runner.win].cursorline = true
		vim.wo[cp_runner.win].number = false
		vim.wo[cp_runner.win].signcolumn = "no"
		vim.wo[cp_runner.win].winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder"

		-- close with q or <Esc> from the output window
		vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = cp_runner.buf, silent = true })
		vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = cp_runner.buf, silent = true })
	end
end

-- write lines into the output buffer (always safe to call from callbacks)
local function cp_write(lines)
	vim.schedule(function()
		if not cp_runner.buf or not vim.api.nvim_buf_is_valid(cp_runner.buf) then
			return
		end
		vim.bo[cp_runner.buf].modifiable = true
		local count = vim.api.nvim_buf_line_count(cp_runner.buf)
		vim.api.nvim_buf_set_lines(cp_runner.buf, count, count, false, lines)
		vim.bo[cp_runner.buf].modifiable = false
		-- keep scrolled to bottom
		if cp_runner.win and vim.api.nvim_win_is_valid(cp_runner.win) then
			local new_count = vim.api.nvim_buf_line_count(cp_runner.buf)
			vim.api.nvim_win_set_cursor(cp_runner.win, { new_count, 0 })
		end
	end)
end

local function cp_clear()
	if cp_runner.buf and vim.api.nvim_buf_is_valid(cp_runner.buf) then
		vim.bo[cp_runner.buf].modifiable = true
		vim.api.nvim_buf_set_lines(cp_runner.buf, 0, -1, false, {})
		vim.bo[cp_runner.buf].modifiable = false
	end
end

-- ─── Kill any running job ────────────────────────────────────────────
local function cp_kill()
	if cp_runner.job then
		pcall(vim.fn.jobstop, cp_runner.job)
		cp_runner.job = nil
	end
end

-- ─── Diff helper (pure lua, no shell needed) ────────────────────────
local function cp_diff_lines(got_lines, ans_lines)
	local out = {}
	local max = math.max(#got_lines, #ans_lines)
	local mismatch = false
	for i = 1, max do
		local g = got_lines[i] or ""
		local a = ans_lines[i] or ""
		-- trim trailing whitespace for comparison (mirrors diff -w)
		local g_trim = g:match("^(.-)%s*$")
		local a_trim = a:match("^(.-)%s*$")
		if g_trim ~= a_trim then
			mismatch = true
			table.insert(out, string.format("  line %d  got: %q", i, g))
			table.insert(out, string.format("  line %d  exp: %q", i, a))
		end
	end
	return mismatch, out
end

-- ─── Core runner ─────────────────────────────────────────────────────
local function cp_run(release_mode)
	-- ── Guard: only works on C++ files ──────────────────────────────
	local ft = vim.bo.filetype
	if ft ~= "cpp" and ft ~= "c" then
		vim.notify("CP Runner: not a C/C++ file (filetype=" .. ft .. ")", vim.log.levels.WARN)
		return
	end

	-- ── Guard: file must exist on disk ──────────────────────────────
	local src = vim.fn.expand("%:p")
	if src == "" or vim.fn.filereadable(src) == 0 then
		vim.notify("CP Runner: buffer has no file on disk — save first", vim.log.levels.WARN)
		return
	end

	-- ── Auto-save ───────────────────────────────────────────────────
	if vim.bo.modified then
		vim.cmd("silent! write")
	end

	-- ── Paths ───────────────────────────────────────────────────────
	local dir = vim.fn.fnamemodify(src, ":h")
	local bin = dir .. "/sol.out"
	local input = dir .. "/in.txt"
	local output = dir .. "/out.txt"
	local ans = dir .. "/ans.txt"

	-- ── Kill previous job ───────────────────────────────────────────
	cp_kill()

	-- ── Open / refresh output window ────────────────────────────────
	cp_win_open()
	cp_clear()

	local mode_label = release_mode and "RELEASE (-O2)" or "DEBUG (asan+ubsan)"
	cp_write({
		"  ⚡ CP Runner",
		"  file : " .. vim.fn.fnamemodify(src, ":t"),
		"  mode : " .. mode_label,
		"  dir  : " .. dir,
		"",
		"  ● Compiling…",
	})

	-- ── Build compile command ────────────────────────────────────────
	local std = ft == "cpp" and "-std=c++17" or "-std=c11"
	local cc = ft == "cpp" and "clang++" or "clang"
	local cflags = {
		cc,
		std,
		"-I" .. CP_HEADER,
		"-Wall",
		"-Wextra",
		"-Wshadow",
	}
	if release_mode then
		vim.list_extend(cflags, { "-O2" })
	else
		vim.list_extend(cflags, { "-g", "-fsanitize=address,undefined" })
	end
	vim.list_extend(cflags, { src, "-o", bin })

	-- ── Phase 1: Compile ────────────────────────────────────────────
	local compile_err = {}

	cp_runner.job = vim.fn.jobstart(cflags, {
		stderr_buffered = true,
		stdout_buffered = true,

		on_stderr = function(_, data)
			if data then
				vim.list_extend(compile_err, data)
			end
		end,

		on_exit = function(_, code)
			vim.schedule(function()
				if code ~= 0 then
					-- ── Compilation failed ─────────────────────────────────
					cp_write({ "  ✗ Compilation FAILED (exit " .. code .. ")", "" })
					-- filter empty trailing lines
					local errs = {}
					for _, l in ipairs(compile_err) do
						if l ~= "" then
							table.insert(errs, "  " .. l)
						end
					end
					cp_write(errs)
					cp_runner.job = nil
					return
				end

				-- ── Phase 2: Run ──────────────────────────────────────────
				cp_write({ "  ✓ Compiled OK", "", "  ● Running (limit: " .. TLE_SECS .. "s)…" })

				-- check in.txt exists; create empty if not
				if vim.fn.filereadable(input) == 0 then
					vim.fn.writefile({}, input)
					cp_write({ "  ⚠  in.txt not found — created empty" })
				end

				local stdout_lines = {}
				local stderr_lines = {}
				local start_ms = vim.uv.now()

				-- use /usr/bin/time on macOS for memory stats
				local run_cmd
				local has_gtime = vim.fn.executable("gtime") == 1
				if has_gtime then
					run_cmd = {
						"bash",
						"-c",
						string.format(
							"gtime -f '%%M' timeout %d %s < %s > %s 2>/tmp/cp_time.txt; echo $?",
							TLE_SECS,
							vim.fn.shellescape(bin),
							vim.fn.shellescape(input),
							vim.fn.shellescape(output)
						),
					}
				else
					run_cmd = {
						"bash",
						"-c",
						string.format(
							"timeout %d %s < %s > %s; echo $?",
							TLE_SECS,
							vim.fn.shellescape(bin),
							vim.fn.shellescape(input),
							vim.fn.shellescape(output)
						),
					}
				end

				cp_runner.job = vim.fn.jobstart(run_cmd, {
					stdout_buffered = true,
					stderr_buffered = true,

					on_stdout = function(_, data)
						if data then
							vim.list_extend(stdout_lines, data)
						end
					end,
					on_stderr = function(_, data)
						if data then
							vim.list_extend(stderr_lines, data)
						end
					end,

					on_exit = function(_, _)
						vim.schedule(function()
							local elapsed_ms = vim.uv.now() - start_ms
							local elapsed = string.format("%.3fs", elapsed_ms / 1000)

							-- exit code is the last stdout line (from echo $?)
							local exit_code = tonumber(stdout_lines[#stdout_lines]) or 0
							-- remove exit code line from stdout
							if #stdout_lines > 0 then
								stdout_lines[#stdout_lines] = nil
							end

							-- read actual program output from file
							local out_lines = vim.fn.filereadable(output) == 1 and vim.fn.readfile(output) or {}

							-- memory (gtime writes kB to /tmp/cp_time.txt)
							local mem_str = "N/A"
							if has_gtime and vim.fn.filereadable("/tmp/cp_time.txt") == 1 then
								local t = vim.fn.readfile("/tmp/cp_time.txt")
								local kb = tonumber(t[1])
								if kb then
									mem_str = string.format("%.2fMB", kb / 1024)
								end
							end

							-- ── Verdict ────────────────────────────────────────
							local verdict, verdict_sym
							if exit_code == 124 then
								-- timeout returns 124
								verdict = "TLE"
								verdict_sym = "⏱ TLE (Time Limit Exceeded)"
							elseif exit_code ~= 0 then
								verdict = "RTE"
								verdict_sym = "💥 RUNTIME ERROR (exit " .. exit_code .. ")"
							else
								-- compare output vs answer if ans.txt exists
								if vim.fn.filereadable(ans) == 1 and vim.fn.getfsize(ans) > 0 then
									local ans_lines = vim.fn.readfile(ans)
									local bad, diff = cp_diff_lines(out_lines, ans_lines)
									if bad then
										verdict = "FAIL"
										verdict_sym = "✗ WRONG ANSWER"
									else
										verdict = "PASS"
										verdict_sym = "✓ ACCEPTED"
									end
								else
									verdict = "OK"
									verdict_sym = "✓ OK (no ans.txt to compare)"
								end
							end

							-- ── Summary block ──────────────────────────────────
							cp_write({
								"",
								"  ┌─────────────────────────────────┐",
								"  │  " .. verdict_sym,
								"  │  time  : " .. elapsed,
								"  │  memory: " .. mem_str,
								"  └─────────────────────────────────┘",
								"",
								"  ── Output ──────────────────────────",
							})

							if #out_lines == 0 then
								cp_write({ "  (no output)" })
							else
								local preview = {}
								for _, l in ipairs(out_lines) do
									table.insert(preview, "  " .. l)
								end
								cp_write(preview)
							end

							-- ── Sanitizer / stderr output ──────────────────────
							local real_stderr = {}
							for _, l in ipairs(stderr_lines) do
								if l ~= "" then
									table.insert(real_stderr, l)
								end
							end
							if #real_stderr > 0 then
								cp_write({
									"",
									"  ── Stderr / Sanitizer ──────────────",
								})
								for _, l in ipairs(real_stderr) do
									cp_write({ "  " .. l })
								end
							end

							-- ── Diff block (FAIL only) ─────────────────────────
							if verdict == "FAIL" then
								local ans_lines = vim.fn.readfile(ans)
								local _, diff = cp_diff_lines(out_lines, ans_lines)
								cp_write({ "", "  ── Diff (got / expected) ───────────" })
								cp_write(diff)
							end

							cp_runner.job = nil
						end)
					end,
				})
			end)
		end,
	})
end

-- ─── Keymaps ─────────────────────────────────────────────────────────

-- Run in debug mode (sanitizers on, reads in.txt, shows diff vs ans.txt)
vim.keymap.set("n", "<leader>rr", function()
	cp_run(false)
end, {
	desc = "CP: compile & run (debug)",
})

-- Run in release mode (-O2, no sanitizers — for timing checks)
vim.keymap.set("n", "<leader>rR", function()
	cp_run(true)
end, {
	desc = "CP: compile & run (release)",
})

-- Kill a running job mid-execution (e.g. infinite loop)
vim.keymap.set("n", "<leader>rk", function()
	cp_kill()
	cp_write({ "", "  ⚠  Job killed by user" })
	vim.notify("CP Runner: job killed", vim.log.levels.WARN)
end, { desc = "CP: kill running job" })

-- Quick-edit in.txt (open in a split, stay focused on sol.cpp)
vim.keymap.set("n", "<leader>ri", function()
	local dir = vim.fn.expand("%:p:h")
	local input = dir .. "/in.txt"
	if vim.fn.filereadable(input) == 0 then
		vim.fn.writefile({}, input)
	end
	vim.cmd("split " .. vim.fn.fnameescape(input))
end, { desc = "CP: edit in.txt" })

-- Quick-edit ans.txt
vim.keymap.set("n", "<leader>ra", function()
	local dir = vim.fn.expand("%:p:h")
	local ans = dir .. "/ans.txt"
	if vim.fn.filereadable(ans) == 0 then
		vim.fn.writefile({}, ans)
	end
	vim.cmd("split " .. vim.fn.fnameescape(ans))
end, { desc = "CP: edit ans.txt" })

-- ============================================================================
-- Mdx code runner otter
-- ============================================================================

local function wrap_cpp(lines)
	local src = table.concat(lines, "\n")
	if src:find("int%s+main%s*%(") then
		return lines
	end -- already complete

	local wrapped = {
		"#include <bits/stdc++.h>",
		"using namespace std;",
		"",
		"int main() {",
		"    ios::sync_with_stdio(false);",
		"    cin.tie(nullptr);",
		"",
	}
	for _, line in ipairs(lines) do
		table.insert(wrapped, "    " .. line)
	end
	table.insert(wrapped, "    return 0;")
	table.insert(wrapped, "}")
	return wrapped
end

local function wrap_c(lines)
	local src = table.concat(lines, "\n")
	if src:find("int%s+main%s*%(") then
		return lines
	end

	local wrapped = {
		"#include <stdio.h>",
		"#include <stdlib.h>",
		"#include <string.h>",
		"",
		"int main(void) {",
	}
	for _, line in ipairs(lines) do
		table.insert(wrapped, "    " .. line)
	end
	table.insert(wrapped, "    return 0;")
	table.insert(wrapped, "}")
	return wrapped
end

local BLOCK_RUNNERS = {
	python = { cmd = "python3", ext = ".py", mode = "interp" },
	py = { cmd = "python3", ext = ".py", mode = "interp" },
	lua = { cmd = "lua", ext = ".lua", mode = "interp" },
	bash = { cmd = "bash", ext = ".sh", mode = "interp" },
	sh = { cmd = "bash", ext = ".sh", mode = "interp" },
	zsh = { cmd = "zsh", ext = ".sh", mode = "interp" },
	javascript = { cmd = "node", ext = ".js", mode = "interp" },
	js = { cmd = "node", ext = ".js", mode = "interp" },
	typescript = { cmd = "ts-node", ext = ".ts", mode = "interp" },
	ts = { cmd = "ts-node", ext = ".ts", mode = "interp" },
	cpp = {
		ext = ".cpp",
		mode = "compile",
		preprocess = wrap_cpp,
		compile = function(src, bin)
			return {
				"clang++",
				"-std=c++17",
				"-O2",
				"-I" .. vim.fn.expand("~/.config/cp/include"),
				src,
				"-o",
				bin,
			}
		end,
	},
	c = {
		ext = ".c",
		mode = "compile",
		preprocess = wrap_c,
		compile = function(src, bin)
			return { "clang", "-std=c11", "-O2", src, "-o", bin }
		end,
	},
	go = { cmd = "go run", ext = ".go", mode = "interp" },
	rust = {
		ext = ".rs",
		mode = "compile",
		compile = function(src, bin)
			return { "rustc", src, "-o", bin }
		end,
	},
}

-- ─── Floating output window (reuses same buffer across runs) ─────────
local md_runner = { buf = nil, win = nil, job = nil }

local function mdr_buf_valid()
	return md_runner.buf and vim.api.nvim_buf_is_valid(md_runner.buf)
end

local function mdr_open_win(title)
	if not mdr_buf_valid() then
		md_runner.buf = vim.api.nvim_create_buf(false, true)
		vim.bo[md_runner.buf].bufhidden = "hide"
		vim.bo[md_runner.buf].swapfile = false
		vim.bo[md_runner.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = md_runner.buf, silent = true })
		vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = md_runner.buf, silent = true })
	end

	local W = math.floor(vim.o.columns * 0.50)
	local H = math.floor(vim.o.lines * 0.75)
	local row = math.floor((vim.o.lines - H) / 2)
	local col = math.floor((vim.o.columns - W) / 2)

	if md_runner.win and vim.api.nvim_win_is_valid(md_runner.win) then
		vim.api.nvim_win_set_config(md_runner.win, {
			relative = "editor",
			width = W,
			height = H,
			row = row,
			col = col,
			title = " " .. title .. " ",
			title_pos = "center",
		})
	else
		md_runner.win = vim.api.nvim_open_win(md_runner.buf, true, {
			relative = "editor",
			width = W,
			height = H,
			row = row,
			col = col,
			style = "minimal",
			border = "rounded",
			title = " " .. title .. " ",
			title_pos = "center",
			zindex = 60,
		})
		vim.wo[md_runner.win].wrap = false
		vim.wo[md_runner.win].cursorline = true
		vim.wo[md_runner.win].number = false
		vim.wo[md_runner.win].signcolumn = "no"
	end
end

local function mdr_write(lines)
	vim.schedule(function()
		if not mdr_buf_valid() then
			return
		end
		vim.bo[md_runner.buf].modifiable = true
		local n = vim.api.nvim_buf_line_count(md_runner.buf)
		vim.api.nvim_buf_set_lines(md_runner.buf, n, n, false, lines)
		vim.bo[md_runner.buf].modifiable = false
		if md_runner.win and vim.api.nvim_win_is_valid(md_runner.win) then
			local new_n = vim.api.nvim_buf_line_count(md_runner.buf)
			vim.api.nvim_win_set_cursor(md_runner.win, { new_n, 0 })
		end
	end)
end

local function mdr_clear()
	if mdr_buf_valid() then
		vim.bo[md_runner.buf].modifiable = true
		vim.api.nvim_buf_set_lines(md_runner.buf, 0, -1, false, {})
		vim.bo[md_runner.buf].modifiable = false
	end
end

local function mdr_kill()
	if md_runner.job then
		pcall(vim.fn.jobstop, md_runner.job)
		md_runner.job = nil
	end
end

-- ─── Treesitter: find code block under cursor ────────────────────────
local function get_code_block_at_cursor()
	local bufnr = vim.api.nvim_get_current_buf()
	local cursor = vim.api.nvim_win_get_cursor(0)
	local row, col = cursor[1], cursor[2]
	row = row - 1 -- convert to 0-indexed

	-- walk up from cursor node to find fenced_code_block
	local ok, node = pcall(vim.treesitter.get_node, { bufnr = bufnr, pos = { row, col } })
	if not ok or not node then
		return nil, "No treesitter node at cursor"
	end

	-- walk up the tree
	local target = node
	while target do
		if target:type() == "fenced_code_block" then
			break
		end
		target = target:parent()
	end

	if not target then
		return nil, "Cursor is not inside a fenced code block"
	end

	-- extract language from info_string → language child
	local lang = nil
	for child in target:iter_children() do
		if child:type() == "info_string" then
			for sub in child:iter_children() do
				if sub:type() == "language" then
					lang = vim.treesitter.get_node_text(sub, bufnr)
					lang = lang:match("^%s*(.-)%s*$"):lower() -- trim + lowercase
					break
				end
			end
		end
	end

	if not lang or lang == "" then
		return nil, "Code block has no language tag (e.g. ```python)"
	end

	-- extract code content from code_fence_content child
	local code_lines = {}
	for child in target:iter_children() do
		if child:type() == "code_fence_content" then
			local text = vim.treesitter.get_node_text(child, bufnr)
			-- split into lines, strip trailing newline
			for line in (text .. "\n"):gmatch("([^\n]*)\n") do
				table.insert(code_lines, line)
			end
			-- remove trailing empty line artefact
			while #code_lines > 0 and code_lines[#code_lines] == "" do
				table.remove(code_lines)
			end
			break
		end
	end

	if #code_lines == 0 then
		return nil, "Code block is empty"
	end

	return { lang = lang, lines = code_lines }, nil
end

-- ─── Core: run a code block ──────────────────────────────────────────
local function run_code_block()
	local ft = vim.bo.filetype
	if ft ~= "markdown" and ft ~= "mdx" then
		vim.notify("Block runner: only works in markdown/mdx files", vim.log.levels.WARN)
		return
	end

	local block, err = get_code_block_at_cursor()
	if not block then
		vim.notify("Block runner: " .. err, vim.log.levels.WARN)
		return
	end

	local runner = BLOCK_RUNNERS[block.lang]
	if not runner then
		vim.notify("Block runner: no runner configured for language '" .. block.lang .. "'", vim.log.levels.WARN)
		return
	end

	-- kill any previous run
	mdr_kill()

	local title = "▶ " .. block.lang
	mdr_open_win(title)
	mdr_clear()
	mdr_write({
		"  ▶ Running " .. block.lang .. " block",
		"  lines: " .. #block.lines,
		"",
	})

	-- write code to a temp file
	local tmpfile = vim.fn.tempname() .. runner.ext
	-- apply preprocessor (e.g. auto-wrap bare C/C++ snippets)
	local lines_to_write = block.lines
	if runner.preprocess then
		lines_to_write = runner.preprocess(vim.deepcopy(block.lines))
	end
	vim.fn.writefile(lines_to_write, tmpfile)

	local stdout_buf = {}
	local stderr_buf = {}
	local start_ms = vim.uv.now()

	local function on_stdout(_, data)
		if data then
			vim.list_extend(stdout_buf, data)
		end
	end
	local function on_stderr(_, data)
		if data then
			vim.list_extend(stderr_buf, data)
		end
	end

	local function on_exit(_, code)
		vim.schedule(function()
			local elapsed = string.format("%.3fs", (vim.uv.now() - start_ms) / 1000)
			local ok_sym = code == 0 and "✓ OK" or ("✗ exit " .. code)

			mdr_write({ "  " .. ok_sym .. "  (" .. elapsed .. ")", "" })

			-- stdout
			if #stdout_buf > 0 then
				mdr_write({
					"  ── Output ────────────────────────────",
				})
				local cleaned = {}
				for _, l in ipairs(stdout_buf) do
					if l ~= "" then
						table.insert(cleaned, "  " .. l)
					end
				end
				if #cleaned == 0 then
					mdr_write({ "  (no output)" })
				else
					mdr_write(cleaned)
				end
			else
				mdr_write({
					"  ── Output ────────────────────────────",
					"  (no output)",
				})
			end

			-- stderr (only if non-empty)
			local real_err = {}
			for _, l in ipairs(stderr_buf) do
				if l ~= "" then
					table.insert(real_err, l)
				end
			end
			if #real_err > 0 then
				mdr_write({
					"",
					"  ── Stderr ─────────────────────────────",
				})
				for _, l in ipairs(real_err) do
					mdr_write({ "  " .. l })
				end
			end

			-- cleanup temp file + binary
			vim.fn.delete(tmpfile)
			local binfile = tmpfile:gsub("%.[^.]+$", "")
			if vim.fn.filereadable(binfile) == 1 then
				vim.fn.delete(binfile)
			end
			md_runner.job = nil
		end)
	end

	if runner.mode == "interp" then
		-- check interpreter exists
		local interp = runner.cmd:match("^(%S+)")
		if vim.fn.executable(interp) == 0 then
			mdr_write({ "  ✗ interpreter not found: " .. interp })
			vim.fn.delete(tmpfile)
			return
		end
		-- split cmd string into list (handles "go run", "ts-node", etc.)
		local cmd = vim.split(runner.cmd, "%s+")
		table.insert(cmd, tmpfile)

		md_runner.job = vim.fn.jobstart(cmd, {
			stdout_buffered = true,
			stderr_buffered = true,
			on_stdout = on_stdout,
			on_stderr = on_stderr,
			on_exit = on_exit,
		})
	elseif runner.mode == "compile" then
		local binfile = tmpfile:gsub("%.[^.]+$", "")
		local compile_cmd = runner.compile(tmpfile, binfile)

		local compile_err = {}
		md_runner.job = vim.fn.jobstart(compile_cmd, {
			stderr_buffered = true,
			on_stderr = function(_, data)
				if data then
					vim.list_extend(compile_err, data)
				end
			end,
			on_exit = function(_, ccode)
				vim.schedule(function()
					if ccode ~= 0 then
						mdr_write({ "  ✗ Compilation failed", "" })
						for _, l in ipairs(compile_err) do
							if l ~= "" then
								mdr_write({ "  " .. l })
							end
						end
						vim.fn.delete(tmpfile)
						md_runner.job = nil
						return
					end
					mdr_write({ "  ✓ Compiled  — running…", "" })
					-- run the binary
					md_runner.job = vim.fn.jobstart({ binfile }, {
						stdout_buffered = true,
						stderr_buffered = true,
						on_stdout = on_stdout,
						on_stderr = on_stderr,
						on_exit = on_exit,
					})
				end)
			end,
		})
	end
end

-- ─── Keymaps ──────────────────────────────────────────────────────────
-- <leader>rr already used by CP runner; use <leader>rb for "run block"
vim.keymap.set("n", "<leader>rb", run_code_block, {
	desc = "MD: run code block under cursor",
})

-- Kill a running block job
vim.keymap.set("n", "<leader>rk", function()
	mdr_kill()
	mdr_write({ "", "  ⚠  Killed by user" })
end, { desc = "MD: kill running block" })

vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = { "markdown", "mdx" },
	callback = function()
		vim.keymap.set("i", "`", "`", { buffer = true, noremap = true })
	end,
})

vim.keymap.set("i", "<Tab>", function()
	local ls = require("luasnip")
	if ls.expandable() then
		ls.expand()
	elseif ls.jumpable(1) then
		ls.jump(1)
	else
		-- fall through to blink
		return vim.api.nvim_replace_termcodes("<Tab>", true, false, true)
	end
end, { expr = true, silent = true, desc = "LuaSnip expand/jump" })
