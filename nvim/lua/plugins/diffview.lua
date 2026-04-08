return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },

  -- Configuration options for Diffview
  opts = {
    hooks = {
      -- This hook fires every time a Diffview window is opened
      view_opened = function()
        -- Permanently forces text to wrap in the diff windows
        vim.opt_local.wrap = true
      end,
    },
  },

  -- Keyboard shortcuts
    keys = {
    {
      "<leader>gd",
      function()
        local lib = require("diffview.lib")
        local current_view = lib.get_current_view()
        if current_view then
          vim.cmd("DiffviewClose")
        else
          vim.cmd("DiffviewOpen")
        end
      end,
      desc = "Toggle DiffView"
    },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Current File History" },
  },
}
