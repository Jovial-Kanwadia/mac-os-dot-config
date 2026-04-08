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
        -- Check if Diffview is currently open
        local lib = require("diffview.lib")
        local view = lib.get_current_view()
        if view then
          -- If it is open, close it
          vim.cmd("DiffviewClose")
        else
          -- If it is closed, open it
          vim.cmd("DiffviewOpen")
        end
      end,
      desc = "Toggle DiffView"
    },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Current File History" },
  },
}
