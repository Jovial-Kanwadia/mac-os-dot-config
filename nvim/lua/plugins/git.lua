-- ============================================================================
-- PLUGINS / GIT  —  gitsigns · diffview
-- ============================================================================

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
