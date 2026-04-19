return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewFileHistory" },

  opts = {
    hooks = {
      diff_buf_win_enter = function(bufnr, winid, ctx)
        vim.opt_local.scrollbind = true
        vim.opt_local.cursorbind = true
      end,
    },
  },

  keys = {
    {
      "<leader>gd",
      function()
        local lib = require("diffview.lib")
        if lib.get_current_view() then
          vim.cmd("DiffviewClose")
        else
          vim.cmd("DiffviewOpen")
        end
      end,
      desc = "Toggle Diff View",
    },
    {
      "<leader>gh",
      function()
        local lib = require("diffview.lib")
        if lib.get_current_view() then
          vim.cmd("DiffviewClose")
        else
          vim.cmd("DiffviewFileHistory %")
        end
      end,
      desc = "Toggle File History",
    },
  },
}
