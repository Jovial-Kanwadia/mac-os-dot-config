return {
  "stevearc/oil.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  lazy = false,

  opts = {
    default_file_explorer = true, -- replaces netrw
    columns = {
      "icon",
    },
    view_options = {
      show_hidden = true,
    },
    float = {
      padding = 2,
      max_width = 100,
      max_height = 30,
      border = "rounded",
    },
    keymaps = {
      ["<CR>"] = "actions.select",
      ["<C-v>"] = "actions.select_vsplit",
      ["<C-s>"] = "actions.select_split",
      ["<C-t>"] = "actions.select_tab",
      ["-"] = "actions.parent",
      ["q"] = "actions.close",
    },
  },

  config = function(_, opts)
    require("oil").setup(opts)

    -- Open Oil with "-"
    vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
  end,
}

