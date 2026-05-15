-- ============================================================================
-- PLUGINS / CP_RUNNER  —  compile · run · diff vs ans.txt
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

-- Run CP script on the current file
vim.keymap.set("n", "<leader>rr", function()
	vim.cmd("write") -- Always save before running
	-- We use the full path to be safe and 'split' to keep the output visible
	vim.cmd("split | term cpr -r " .. vim.fn.expand("%"))
end, { desc = "CP: Save and Run" })

-- Run in debug mode (sanitizers on, reads in.txt, shows diff vs ans.txt)
--vim.keymap.set("n", "<leader>rr", function()
--	cp_run(false)
--end, {
--	desc = "CP: compile & run (debug)",
--})

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
