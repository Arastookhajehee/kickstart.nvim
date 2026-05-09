vim.pack.add({
  "https://github.com/3rd/image.nvim",
})

require("image").setup({
  backend = "kitty",
  processor = "magick_cli",
  kitty_method = "stream", -- important for Ghostty

  integrations = {
    markdown = {
      enabled = true,
      clear_in_insert_mode = false,
      download_remote_images = true,
      only_render_image_at_cursor = false,
      filetypes = { "markdown", "vimwiki" },
    },
    neorg = { enabled = true },
    typst = { enabled = true },
    html = { enabled = false },
    css = { enabled = false },
  },

  max_height_window_percentage = 75,
  max_width_window_percentage = 75,
  hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" },
})
