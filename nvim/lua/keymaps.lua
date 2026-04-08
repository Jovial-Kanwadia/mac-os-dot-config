local map = vim.keymap.set
local builtin = require("telescope.builtin")
local harpoon = require("harpoon")

vim.keymap.set("n", "<leader>ff", builtin.find_files,  { desc = "Find Files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep,   { desc = "Live Grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers,     { desc = "Buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags,   { desc = "Help Tags" })
vim.keymap.set("n", "<leader>fr", builtin.oldfiles,    { desc = "Recent Files" })
vim.keymap.set("n", "<leader>fc", builtin.commands,    { desc = "Commands" })
vim.keymap.set("n", "<CR>", "o<Esc>", { desc = "Add new line below" })

-- Neo-tree toggle 
map("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "Neo-tree Toggle" })

-- Harpoon
map("n", "<leader>a", function()
  harpoon:list():add()
end, { desc = "Harpoon: Add file" })

map("n", "<leader>h", function()
  harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = "Harpoon: Toggle menu" })

map("n", "]h", function()
  harpoon:list():next()
end, { desc = "Harpoon: Next" })

map("n", "[h", function()
  harpoon:list():prev()
end, { desc = "Harpoon: Prev" })

-- Quick jumps to slot 1..4
map("n", "<leader>1", function() harpoon:list():select(1) end)
map("n", "<leader>2", function() harpoon:list():select(2) end)
map("n", "<leader>3", function() harpoon:list():select(3) end)
map("n", "<leader>4", function() harpoon:list():select(4) end)

-- use Telescope to list harpoon marks
map("n", "<leader>fm", function()
  pcall(function()
    require("telescope").load_extension("harpoon")
    require("telescope").extensions.harpoon.marks()
  end)
end, { desc = "Telescope: Harpoon marks" })

vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

