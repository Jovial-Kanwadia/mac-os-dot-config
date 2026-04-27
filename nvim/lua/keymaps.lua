local attachments_dir = vim.fn.expand("~/programming/notes/attachments")
local relative_folder = "attachments" -- Use this for the Markdown link

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
		-- entry_to_file cleanly strips icons/garbage
		local entry_path = path.entry_to_file(entry, self.opts).path
		local filepath = attachments_dir .. "/" .. entry_path

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
		cwd = attachments_dir,
		prompt = "Insert Image> ",
		previewer = image_previewer,
		actions = {
			["default"] = function(selected)
				-- Get ONLY the filename (the tail), ignoring any absolute paths
				local filename = vim.fn.fnamemodify(path.entry_to_file(selected[1]).path, ":t")
				local link = string.format("![](%s/%s)", relative_folder, filename)
				vim.api.nvim_put({ link }, "c", true, true)
			end,
		},
	})
end, { desc = "Insert Image (fzf-lua)" })

vim.keymap.set("n", "<leader>pp", function()
	require("img-clip").paste_image()
end, { desc = "Paste image from clipboard" })

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
