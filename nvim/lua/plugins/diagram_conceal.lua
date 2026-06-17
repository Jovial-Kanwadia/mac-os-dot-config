-- lua/plugins/diagram_conceal.lua
local api = vim.api
local AG = api.nvim_create_augroup("DiagramConceal", { clear = true })
local state = {}

-- Parse blocks using 1-indexed line numbers for easy vim.cmd math
local function get_blocks(bufnr)
	local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local blocks = {}
	local i = 1
	while i <= #lines do
		local ticks = lines[i]:match("^%s*(`+)%s*[Mm][Ee][Rr][Mm][Aa][Ii][Dd]%s*$")
		if ticks then
			local s = i -- 1-indexed
			i = i + 1
			while i <= #lines do
				local close = lines[i]:match("^%s*(`+)%s*$")
				if close and #close >= #ticks then
					table.insert(blocks, { start_line = s, end_line = i })
					break
				end
				i = i + 1
			end
		end
		i = i + 1
	end
	return blocks
end

local function apply_folds(bufnr)
	local s = state[bufnr]
	if not s then
		return
	end

	local cursor_row = api.nvim_win_get_cursor(0)[1] -- 1-indexed

	for _, block in ipairs(s.blocks) do
		local is_inside = cursor_row >= block.start_line and cursor_row <= block.end_line

		-- We check if the content line (start_line + 1) is folded
		local content_line = block.start_line + 1
		local is_folded = vim.fn.foldclosed(content_line) ~= -1

		-- Only fold if there is actually content to fold
		if content_line <= block.end_line then
			if is_inside and is_folded then
				-- Unfold the content
				vim.cmd(string.format("silent! %d,%dfoldopen!", content_line, block.end_line))
			elseif not is_inside and not is_folded then
				-- Fold ONLY the content, leaving the ```mermaid anchor line completely visible
				vim.cmd(string.format("silent! %d,%dfold", content_line, block.end_line))
			end
		end
	end
end

local function attach(bufnr)
	state[bufnr] = { blocks = get_blocks(bufnr) }

	-- Setup manual folding for this specific buffer
	vim.opt_local.foldmethod = "manual"

	-- Clean UI text for the hidden code
	_G.mermaid_fold_text = function()
		return " ⋯ "
	end
	vim.opt_local.foldtext = "v:lua.mermaid_fold_text()"
	vim.opt_local.fillchars:append({ fold = " " })

	api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
		group = AG,
		buffer = bufnr,
		callback = function()
			apply_folds(bufnr)
		end,
	})

	api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
		group = AG,
		buffer = bufnr,
		callback = function()
			state[bufnr].blocks = get_blocks(bufnr)
		end,
	})

	-- Initial collapse
	vim.defer_fn(function()
		if api.nvim_buf_is_valid(bufnr) then
			apply_folds(bufnr)
		end
	end, 300)
end

api.nvim_create_autocmd("FileType", {
	group = AG,
	pattern = { "markdown", "mdx" },
	callback = function(ev)
		attach(ev.buf)
	end,
})
