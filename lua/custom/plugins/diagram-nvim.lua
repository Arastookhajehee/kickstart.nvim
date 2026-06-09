vim.pack.add({
  "https://github.com/3rd/image.nvim",
  "https://github.com/3rd/diagram.nvim",
})

local mermaid_css = vim.fn.stdpath("cache") .. "/diagram-mermaid.css"

vim.fn.writefile({
  [[text,]],
  [[.nodeLabel,]],
  [[.edgeLabel {]],
  [[  font-size: 14px !important;]],
  [[  font-family: "0xProto Nerd Font Mono", monospace !important;]],
  [[}]],
  [[]],
  [[.node foreignObject {]],
  [[  overflow: visible !important;]],
  [[}]],
  [[]],
  [[.node .label,]],
  [[.node .label > div,]],
  [[.node .label > span,]],
  [[.nodeLabel {]],
  [[  margin: 0 !important;]],
  [[  padding: 0 !important;]],
  [[  line-height: 1.05 !important;]],
  [[  display: block !important;]],
  [[  width: 100% !important;]],
  [[  text-align: center !important;]],
  [[  white-space: pre-line !important;]],
  [[  box-sizing: border-box !important;]],
  [[}]],
  [[]],
  [[.node rect {]],
  [[  rx: 10px !important;]],
  [[  ry: 10px !important;]],
  [[}]],
}, mermaid_css)

require("image").setup({
  backend = "kitty",
  processor = "magick_cli",
  kitty_method = "stream",
  scale_factor = 1,
  max_width_window_percentage = 100,
  max_height_window_percentage = 50,

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

  hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" },
})

require("diagram").setup({
  integrations = {
    require("diagram.integrations.markdown"),
    require("diagram.integrations.neorg"),
  },

  renderer_options = {
    mermaid = {
      theme = "dark",
      background = "transparent",

      cli_args = {
        "--width", "600",
        "--scale", "4",
        "--cssFile", mermaid_css,
      },

      config = {
        flowchart = {
          htmlLabels = true,
          useMaxWidth = false,
          padding = 2,
        },
      },
    },
  },
})
