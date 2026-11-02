if vim.fn.has 'win32' == 1 then
  -- image.nvim queries terminal cell size with Unix ioctl; Windows has no ioctl.
  -- Use a configurable cell-size estimate until it supports Windows natively.
  package.preload['image/utils/term'] = function()
    local cell_width = tonumber(vim.env.NVIM_IMAGE_CELL_WIDTH) or 8
    local cell_height = tonumber(vim.env.NVIM_IMAGE_CELL_HEIGHT) or 16

    return {
      get_size = function()
        local cols, rows = vim.o.columns, vim.o.lines
        return {
          screen_x = cols * cell_width,
          screen_y = rows * cell_height,
          screen_cols = cols,
          screen_rows = rows,
          cell_width = cell_width,
          cell_height = cell_height,
        }
      end,
      get_tty = function() return nil end,
    }
  end
end

-- image.nvim converts JPEGs to PNG without applying their EXIF orientation.
-- Normalize the temporary copy so dimensions and display orientation agree.
local magick_cli = require 'image/processors/magick_cli'
local convert_to_png = magick_cli.convert_to_png
magick_cli.convert_to_png = function(path, output_path)
  if not path:lower():match '%.jpe?g$' or vim.fn.executable 'magick' ~= 1 then
    return convert_to_png(path, output_path)
  end

  local result = vim.system({ 'magick', path, '-auto-orient', 'png:' .. output_path }):wait()
  if result.code ~= 0 then error('image.nvim: failed to auto-orient JPEG: ' .. (result.stderr or '')) end
  return output_path
end

require('image').setup {
  backend = 'kitty',
  processor = 'magick_cli',
  kitty_method = 'stream',
  scale_factor = 1,
  max_width_window_percentage = 100,
  max_height_window_percentage = 50,
  integrations = {
    markdown = {
      enabled = true,
      clear_in_insert_mode = false,
      download_remote_images = true,
      only_render_image_at_cursor = false,
      filetypes = { 'markdown', 'vimwiki' },
    },
    neorg = { enabled = true },
    typst = { enabled = true },
    html = { enabled = false },
    css = { enabled = false },
  },
  hijack_file_patterns = { '*.png', '*.jpg', '*.jpeg', '*.gif', '*.webp', '*.avif' },
}
