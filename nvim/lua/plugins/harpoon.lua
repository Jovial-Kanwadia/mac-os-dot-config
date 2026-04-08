return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  lazy = false,
  opts = {
    global_settings = {
      save_on_toggle = true,
      save_on_change = true,
      enter_on_sendcmd = false,
    },
    menu = { width = 60, height = 10, },
  },
}

