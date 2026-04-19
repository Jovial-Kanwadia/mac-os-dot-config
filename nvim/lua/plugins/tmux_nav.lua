-- vim-tmux-navigator: seamless Ctrl+h/j/k/l between nvim splits and tmux panes
return {
  "christoomey/vim-tmux-navigator",
  lazy = false,
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
  },
  keys = {
    { "<C-h>", "<cmd>TmuxNavigateLeft<cr>",  desc = "Navigate Left" },
    { "<C-j>", "<cmd>TmuxNavigateDown<cr>",  desc = "Navigate Down" },
    { "<C-k>", "<cmd>TmuxNavigateUp<cr>",    desc = "Navigate Up" },
    { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Navigate Right" },
  },
}
