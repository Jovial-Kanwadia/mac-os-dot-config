return {
  "nvim-telescope/telescope.nvim",
  version = "*", -- pin to latest
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-ui-select.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
    },
  },
  config = function()
    local telescope = require("telescope")
    require("telescope").setup({
      defaults = {
        prompt_prefix = "🔍 ",  -- nicer prompt
        selection_caret = "❯ ",
        path_display = { "smart" },
        sorting_strategy = "ascending",
      },
      pickers = {
        find_files = {
          hidden = true,       -- show hidden files
        },
      },
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
        ["ui-select"] = {
            require("telescope.themes").get_dropdown({})
        },
      },
    })

    -- load extensions
    telescope.load_extension("fzf")
    telescope.load_extension("ui-select")
  end,
}

