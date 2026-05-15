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

-- re-enter insert when jumping back into the terminal window
vim.api.nvim_create_autocmd("BufEnter", {
	group = term_augroup,
	callback = function()
		if term.buf and vim.api.nvim_get_current_buf() == term.buf then
			vim.cmd("startinsert")
		end
	end,
})

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
