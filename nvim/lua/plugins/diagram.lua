-- lua/plugins/diagram.lua
require("diagram").setup({
	integrations = {
		require("diagram.integrations.markdown"),
	},

	renderer_options = {
		mermaid = {
			background = "transparent",
			theme = "dark",
			scale = 3, -- 3x for sharp rendering in kitty
			extra_args = {
				"-p",
				vim.fn.expand("~/.config/mmdc/puppeteer-config.json"),
				"-s",
				"4", -- 4x resolution, auto-cropped tight to the diagram!
			},
		},
	},

	-- when to re-render (these are the defaults, adjust as you like)
	events = {
		render_buffer = { "InsertLeave", "BufWinEnter", "TextChanged" },
		clear_buffer = { "BufLeave" },
	},
})
