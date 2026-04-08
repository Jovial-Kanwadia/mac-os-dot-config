return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      flavour = "frappe",
      transparent_background = true,
      term_colors = true,
      integrations = {
        cmp = true,
        gitsigns = true,
        treesitter = true,
        mini = {
          enabled = true,
          indentscope_color = "",
        },
        telescope = true,
        which_key = true,
        neotree = true,
      },
    })
    vim.cmd.colorscheme("catppuccin")
  end,
}
