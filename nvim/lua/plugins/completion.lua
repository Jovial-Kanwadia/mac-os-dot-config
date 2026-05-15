-- ============================================================================
-- PLUGINS / COMPLETION  —  blink.cmp · LuaSnip
-- ============================================================================

-- Code block snippets for markdown
local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

ls.add_snippets("markdown", {
	s("cpp", fmt("```cpp\n{}\n```", { i(1) })),
	s("c", fmt("```c\n{}\n```", { i(1) })),
	s("py", fmt("```python\n{}\n```", { i(1) })),
	s("lua", fmt("```lua\n{}\n```", { i(1) })),
	s("sh", fmt("```bash\n{}\n```", { i(1) })),
	s("js", fmt("```javascript\n{}\n```", { i(1) })),
	s("ts", fmt("```typescript\n{}\n```", { i(1) })),
	s("go", fmt("```go\n{}\n```", { i(1) })),
	s("rs", fmt("```rust\n{}\n```", { i(1) })),
	s("cb", fmt("```{}\n{}\n```", { i(1, "lang"), i(2) })),
})

require("blink.cmp").setup({
	keymap = {
		preset = "none",
		["<C-Space>"] = { "show", "hide" },
		["<CR>"] = { "accept", "fallback" },
		["<C-j>"] = { "select_next", "fallback" },
		["<C-k>"] = { "select_prev", "fallback" },
		["<Tab>"] = { "snippet_forward", "fallback" },
		["<S-Tab>"] = { "snippet_backward", "fallback" },
	},
	appearance = { nerd_font_variant = "mono" },
	completion = { menu = { auto_show = true } },
	sources = {
		default = { "lsp", "path", "buffer", "snippets" },
		providers = {
			otter = {
				name = "otter",
				module = "otter.completion.blink",
			},
		},
	},
	snippets = {
		expand = function(snippet)
			require("luasnip").lsp_expand(snippet)
		end,
	},

	fuzzy = {
		implementation = "prefer_rust",
	},
})
