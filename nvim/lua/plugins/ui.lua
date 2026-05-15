-- ============================================================================
-- PLUGINS / UI  —  oil · mason · mini · image · img-clip · otter · render-md
-- ============================================================================

-- oil
require("oil").setup({
	view_options = {
		show_hidden = true,
	},
})

vim.keymap.set("n", "-", function()
	require("oil").open()
end, { desc = "Open Parent Directory" })

-- Mason
require("mason").setup({})

-- otter.nvim
require("otter").setup({
	lsp = {
		hover = true,
		set_filetype = true,
	},
	buffers = {
		write_to_disk = false,
	},
	handle_leading_whitespace = true,
})

-- Mini Modules
require("mini.ai").setup({})
require("mini.comment").setup({})
require("mini.move").setup({})
require("mini.surround").setup({})
require("mini.cursorword").setup({})
require("mini.indentscope").setup({})
require("mini.pairs").setup({})
require("mini.trailspace").setup({})
require("mini.bufremove").setup({})
require("mini.notify").setup({})
require("mini.icons").setup({})

-- image.nvim (kitty protocol image rendering)
require("image").setup({
	backend = "kitty",
	editor_only_render_when_focused = true,
	kitty_method = "unicode_placeholders",
	tmux_passthrough = true,
	max_width = 80,
	max_height = 16,
	integrations = {
		markdown = {
			enabled = true,
			clear_in_insert_mode = false,
			download_remote_images = false,
			only_render_image_at_cursor = false,
			only_render_image_at_cursor_mode = "inline", -- "popup" is the alternative
			filetypes = { "markdown", "vimwiki" },
		},
	},
})

-- img-clip (paste images from clipboard into markdown)
require("img-clip").setup({
	default = {
		dir_path = "attachments",
		relative_to_current_file = true, -- dir_path is resolved next to the open file
		use_absolute_path = false, -- insert a relative path into the buffer
		extension = "png",
		file_name = "%Y%m%d-%H%M%S", -- e.g. 20250426-143022.png
		template = "![$CURSOR]($FILE_PATH)",
		prompt_for_file_name = false, -- no interactive prompt; just paste
		insert_mode_after_paste = false, -- stay in normal mode after pasting
		post_paste_cmd = function()
			local ok, image = pcall(require, "image")
			if ok then
				vim.defer_fn(function()
					image.clear() -- clear stale placements
					vim.cmd("doautocmd CursorMoved")
				end, 50)
			end
		end,
	},
	filetypes = {
		markdown = {
			-- Override dir_path per-filetype if you want a different folder name
			dir_path = "attachments",
		},
	},
})

-- render-markdown.nvim
require("render-markdown").setup({
	render_modes = { "n", "c", "t" },

	heading = {
		sign = false,
		width = "block",
		left_pad = 1,
		right_pad = 4,
		icons = { "󰲡  ", "󰲣  ", "󰲥  ", "󰲧  ", "󰲩  ", "󰲫  " },
	},

	code = {
		sign = false,
		style = "full", -- language icon + background
		border = "thin", -- ▄ top / ▀ bottom lines
		above = "▄",
		below = "▀",
		width = "block", -- background only as wide as the code, not full window
		left_pad = 2,
		right_pad = 2,
		language_pad = 1,
		position = "left",
		language_icon = true,
		language_name = true,
		language_left = "█",
		language_right = "█",
		language_border = "▁",
	},

	-- render inside insert mode too so you see styling while typing
	-- (anti_conceal reveals the raw ``` when cursor is on that line)
	anti_conceal = {
		enabled = true,
		ignore = {
			code_background = true,
			indent = true,
			sign = true,
		},
	},

	debounce = 50,
})
