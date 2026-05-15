-- ============================================================================
-- PLUGINS / EDITOR  —  harpoon · fzf-lua · undotree · tmux · image keymaps
-- ============================================================================

-- fzf
require("fzf-lua").setup({})

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

-- undotree
vim.keymap.set("n", "<leader>u", "<cmd>UndotreeToggle<cr>", { desc = "Toggle Undotree" })

-- nvim-tmux-navigator
vim.keymap.set("n", "<C-h>", "<cmd>TmuxNavigateLeft<cr>", { desc = "Window Left" })
vim.keymap.set("n", "<C-j>", "<cmd>TmuxNavigateDown<cr>", { desc = "Window Down" })
vim.keymap.set("n", "<C-k>", "<cmd>TmuxNavigateUp<cr>", { desc = "Window Up" })
vim.keymap.set("n", "<C-l>", "<cmd>TmuxNavigateRight<cr>", { desc = "Window Right" })
