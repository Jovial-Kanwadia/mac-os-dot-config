local map = vim.keymap.set
local builtin = require("telescope.builtin")

vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live Grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help Tags" })
vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Recent Files" })
vim.keymap.set("n", "<leader>fc", builtin.commands, { desc = "Commands" })
vim.keymap.set("n", "<CR>", function()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_buf_set_lines(0, row, row, false, { "" })
  vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
end, { desc = "Add new line below" })

vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<cr>", { desc = "Goto Definition" })
vim.keymap.set("n", "gr", "<cmd>Telescope lsp_references<cr>", { desc = "Goto References" })

vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "Neo-tree Toggle" })

local harpoon = require("harpoon")

vim.keymap.set("n", "<leader>a", function()
  harpoon:list():add()
end, { desc = "Harpoon: Add file" })

vim.keymap.set("n", "<leader>hh", function()
  harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = "Harpoon: Toggle menu" })

vim.keymap.set("n", "<leader>hn", function()
  harpoon:list():next()
end, { desc = "Harpoon: Next mark" })

vim.keymap.set("n", "<leader>hp", function()
  harpoon:list():prev()
end, { desc = "Harpoon: Previous mark" })

vim.keymap.set("n", "<leader>1", function()
  harpoon:list():select(1)
end, { desc = "Harpoon: Jump to mark 1" })

vim.keymap.set("n", "<leader>2", function()
  harpoon:list():select(2)
end, { desc = "Harpoon: Jump to mark 2" })

vim.keymap.set("n", "<leader>3", function()
  harpoon:list():select(3)
end, { desc = "Harpoon: Jump to mark 3" })

vim.keymap.set("n", "<leader>4", function()
  harpoon:list():select(4)
end, { desc = "Harpoon: Jump to mark 4" })

vim.keymap.set("n", "<leader>hm", function()
  pcall(function()
    require("telescope").load_extension("harpoon")
    require("telescope").extensions.harpoon.marks()
  end)
end, { desc = "Telescope: Harpoon marks" })

vim.keymap.set("n", "<leader>pi", function()
  local attachments_dir = vim.fn.expand("~/programming/notes/attachments")

  local image_previewer = require("telescope.previewers").new_buffer_previewer({
    title = "Image Preview",
    define_preview = function(self, entry, status)
      local filepath = attachments_dir .. "/" .. entry.value
      local ext = (filepath:match("%.(%w+)$") or ""):lower()
      local supported = { png = true, jpg = true, jpeg = true, gif = true, webp = true }

      -- Clear previous render
      if self.state._image then
        self.state._image:clear()
        self.state._image = nil
      end

      if not supported[ext] then
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, { "", "  Not a supported image file." })
        return
      end

      local ok, image_api = pcall(require, "image")
      if not ok then return end

      vim.schedule(function()
        local img = image_api.from_file(filepath, {
          window = status.preview_win,
          buffer = self.state.bufnr,
          with_virtual_padding = true,
          max_width = 80,
          max_height = 40,
        })
        if img then
          self.state._image = img
          img:render()
        end
      end)
    end,
  })

  require("telescope.builtin").find_files({
    cwd = attachments_dir,
    prompt_title = "Insert Image",
    previewer = image_previewer,
    attach_mappings = function(_, map)
      map("i", "<CR>", function(prompt_bufnr)
        local entry = require("telescope.actions.state").get_selected_entry()
        local filename = entry[1]:match("([^/]+)$")
        local link = string.format("![alt](%s/%s)", attachments_dir, filename)
        require("telescope.actions").close(prompt_bufnr)
        vim.api.nvim_put({ link }, "c", true, true)
      end)
      return true
    end,
  })
end, { desc = "Insert Image" })

local function paste_image_from_clipboard()
  local attachments_dir = vim.fn.expand("~/programming/notes/attachments")
  if vim.fn.isdirectory(attachments_dir) == 0 then
    vim.fn.mkdir(attachments_dir, "p")
  end

  if vim.fn.executable("pngpaste") == 0 then
    vim.notify("pngpaste is not installed. Run: brew install pngpaste", vim.log.levels.ERROR)
    return
  end

  local filename = os.date("img-%Y%m%d-%H%M%S") .. ".png"
  local filepath = attachments_dir .. "/" .. filename

  local result = vim.system({ "pngpaste", filepath }):wait()
  if result.code ~= 0 then
    vim.notify("No image found in clipboard", vim.log.levels.ERROR)
    return
  end

  local link = string.format("![alt](%s/%s)", vim.fn.expand("~/programming/notes/attachments"), filename)
  vim.api.nvim_put({ link }, "c", true, true)
end

vim.keymap.set("n", "<leader>pp", paste_image_from_clipboard, { desc = "Paste image from clipboard" })

vim.keymap.set("n", "<leader>ds", function()
  -- Open split
  vim.cmd("vsplit")
  -- Start terminal with absolute path
  vim.cmd("term " .. vim.fn.expand("~") .. "/.local/bin/ds.sh")
  -- Force insert mode (extra safety)
  vim.cmd("startinsert")
end)

-- Close terminal buffer with 'q' when the process is finished
vim.api.nvim_create_autocmd("TermClose", {
  callback = function()
    vim.keymap.set("n", "q", "<cmd>bdelete!<CR>", { buffer = true, silent = true })
  end,
})

vim.keymap.set("n", "<leader>DK", function()
  local ft = vim.bo.filetype
  local word = vim.fn.expand("<cword>")
  -- Map nvim filetypes to DevDocs slugs if they differ
  local ft_map = {
    cpp = "cpp",
    rust = "rust",
    python = "python",
    javascript = "javascript",
    lua = "lua"
  }
  local doc_lang = ft_map[ft] or ft
  -- Opens dedoc directly for the word under your cursor
  vim.cmd("vsplit | term dedoc open " .. doc_lang .. " " .. word .. " | less -R")
end, { desc = "[D]oc [K]eyword Search" })

vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv", { noremap = true, silent = true })
vim.keymap.set("n", "N", "Nzzzv", { noremap = true, silent = true })
