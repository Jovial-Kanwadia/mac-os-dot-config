-- ============================================================================
-- PLUGINS / MD_RUNNER  —  run fenced code blocks in markdown/mdx files
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

-- Run code block
vim.keymap.set("n", "<leader>rb", run_code_block, {
	desc = "MD: run code block under cursor",
})

-- Kill a running block job
vim.keymap.set("n", "<leader>rK", function()
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
