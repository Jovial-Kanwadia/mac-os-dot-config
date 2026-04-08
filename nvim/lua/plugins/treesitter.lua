return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },

  opts = {
    ensure_installed = {
      "c",
      "cpp",
      "objc",
      "lua",
      "vim",
      "vimdoc",
      "bash",
      "json",
      "go",
      "rust",
      "python",
      "markdown",
      "markdown_inline",
    },

    auto_install = true,

    highlight = {
      enable = true,
    },

    indent = {
      enable = true,
    },

    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<C-space>",
        node_incremental = "<C-space>",
        node_decremental = "<BS>",
      },
    },
  },

}

