return {
  "3rd/image.nvim",
  opts = {
    backend = "kitty",
    processor_thread_count = 4,
    editor_only_render_when_focused = true, 
    tmux_passthrough = true,
    
    integrations = {
      markdown = {
        enabled = true,
        clear_in_insert_mode = true,
        download_remote_images = false,
        filetypes = { "markdown", "vimwiki" },
      },
    },
    max_width = 80,
    max_height = 20,
    window_overlap_clear_enabled = true,
  },
}
