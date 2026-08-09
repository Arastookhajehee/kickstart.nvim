vim.pack.add {
  -- 'https://github.com/nvim-treesitter/nvim-treesitter',
  'https://github.com/nvim-mini/mini.nvim', -- if you use the mini.nvim suite
  -- 'https://github.com/nvim-mini/mini.icons',        -- if you use standalone mini plugins
  -- 'https://github.com/nvim-tree/nvim-web-devicons', -- if you prefer nvim-web-devicons
  'https://github.com/MeanderingProgrammer/render-markdown.nvim',
}

local function set_markdown_render_highlights()
  local normal = vim.api.nvim_get_hl(0, { name = 'Normal', link = false })
  local fg = normal and normal.fg or 0xe0def4
  local bg = normal and normal.bg or nil
  local colors = {
    h1 = 0xbd93f9,
    h2 = 0xffb86c,
    h3 = 0x50fa7b,
    h4 = 0xbd93f9,
    h5 = 0x8be9fd,
    h6 = 0xf1fa8c,
    link = 0x50fa7b,
    bullet = 0xffb86c,
    table_line = 0x6f737c,
  }

  -- local heading_groups = {
    -- { 'RenderMarkdownH1', colors.h1 },
    -- { 'RenderMarkdownH2', colors.h2 },
    -- { 'RenderMarkdownH3', colors.h3 },
    -- { 'RenderMarkdownH4', colors.h4 },
    -- { 'RenderMarkdownH5', colors.h5 },
    -- { 'RenderMarkdownH6', colors.h6 },
    -- { 'RenderMarkdownH1Bg', colors.h1 },
    -- { 'RenderMarkdownH2Bg', colors.h2 },
    -- { 'RenderMarkdownH3Bg', colors.h3 },
    -- { 'RenderMarkdownH4Bg', colors.h4 },
    -- { 'RenderMarkdownH5Bg', colors.h5 },
    -- { 'RenderMarkdownH6Bg', colors.h6 },
    -- { '@markup.heading.1', colors.h1 },
    -- { '@markup.heading.2', colors.h2 },
    -- { '@markup.heading.3', colors.h3 },
    -- { '@markup.heading.4', colors.h4 },
    -- { '@markup.heading.5', colors.h5 },
    -- { '@markup.heading.6', colors.h6 },
    -- { '@markup.heading.1.markdown', colors.h1 },
    -- { '@markup.heading.2.markdown', colors.h2 },
    -- { '@markup.heading.3.markdown', colors.h3 },
    -- { '@markup.heading.4.markdown', colors.h4 },
    -- { '@markup.heading.5.markdown', colors.h5 },
    -- { '@markup.heading.6.markdown', colors.h6 },
    -- { '@text.title.1', colors.h1 },
    -- { '@text.title.2', colors.h2 },
    -- { '@text.title.3', colors.h3 },
    -- { '@text.title.4', colors.h4 },
    -- { '@text.title.5', colors.h5 },
    -- { '@text.title.6', colors.h6 },
    -- { '@text.title.1.markdown', colors.h1 },
    -- { '@text.title.2.markdown', colors.h2 },
    -- { '@text.title.3.markdown', colors.h3 },
    -- { '@text.title.4.markdown', colors.h4 },
    -- { '@text.title.5.markdown', colors.h5 },
    -- { '@text.title.6.markdown', colors.h6 },
  -- }

  vim.api.nvim_set_hl(0, '@markup.heading', { fg = fg, bg = bg, bold = true })
  vim.api.nvim_set_hl(0, '@markup.heading.markdown', { fg = fg, bg = bg, bold = true })
  vim.api.nvim_set_hl(0, '@text.title', { fg = fg, bg = bg, bold = true })
  vim.api.nvim_set_hl(0, '@text.title.markdown', { fg = fg, bg = bg, bold = true })

  -- for _, group in ipairs(heading_groups) do
  --   vim.api.nvim_set_hl(0, group[1], { fg = group[2], bg = bg, bold = true })
  -- end

  vim.api.nvim_set_hl(0, 'RenderMarkdownBullet', { fg = colors.bullet })
  vim.api.nvim_set_hl(0, 'RenderMarkdownLink', { fg = colors.link, underline = true })
  vim.api.nvim_set_hl(0, '@markup.link', { fg = colors.link, underline = true })
  vim.api.nvim_set_hl(0, '@markup.link.markdown_inline', { fg = colors.link, underline = true })
  vim.api.nvim_set_hl(0, '@markup.link.label', { fg = colors.link, underline = true })
  vim.api.nvim_set_hl(0, '@markup.link.label.markdown_inline', { fg = colors.link, underline = true })
  vim.api.nvim_set_hl(0, '@text.reference', { fg = colors.link, underline = true })
  vim.api.nvim_set_hl(0, '@text.reference.markdown_inline', { fg = colors.link, underline = true })
  vim.api.nvim_set_hl(0, '@punctuation.special.markdown', { fg = colors.table_line })
  vim.api.nvim_set_hl(0, 'RenderMarkdownTableBorder', { fg = colors.table_line, bg = bg })
  vim.api.nvim_set_hl(0, 'RenderMarkdownTableHead', { fg = fg, bg = bg, bold = true })
  vim.api.nvim_set_hl(0, 'RenderMarkdownTableRow', { fg = fg, bg = bg })
end

require('render-markdown').setup {
  preset = 'obsidian',
  render_modes = { 'n', 'c', 't' },
  on = {
    render = set_markdown_render_highlights,
  },
  code = {
    conceal_delimiters = false,
    border = 'thin',
  },
  heading = {
    icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
    position = 'inline',
    width = 'block',
    left_pad = 0,
    right_pad = 0,
    border = false,
    backgrounds = {
      'RenderMarkdownH1Bg',
      'RenderMarkdownH2Bg',
      'RenderMarkdownH3Bg',
      'RenderMarkdownH4Bg',
      'RenderMarkdownH5Bg',
      'RenderMarkdownH6Bg',
    },
    foregrounds = {
      'RenderMarkdownH1',
      'RenderMarkdownH2',
      'RenderMarkdownH3',
      'RenderMarkdownH4',
      'RenderMarkdownH5',
      'RenderMarkdownH6',
    },
  },
  bullet = {
    icons = { '•', '◦', '▪', '▫' },
    right_pad = 1,
  },
  pipe_table = {
    cell = 'trimmed',
    padding = 1,
    min_width = 3,
    border_enabled = true,
    alignment_indicator = '─',
    head = 'RenderMarkdownTableBorder',
    row = 'RenderMarkdownTableBorder',
  },
  link = {
    hyperlink = '',
    image = '',
    email = '',
    custom = {},
  },
} -- only mandatory if you want to set custom options

set_markdown_render_highlights()
vim.api.nvim_create_autocmd('ColorScheme', {
  callback = set_markdown_render_highlights,
})
