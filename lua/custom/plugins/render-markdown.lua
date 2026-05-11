vim.pack.add({
    -- 'https://github.com/nvim-treesitter/nvim-treesitter',
    'https://github.com/nvim-mini/mini.nvim',            -- if you use the mini.nvim suite
    -- 'https://github.com/nvim-mini/mini.icons',        -- if you use standalone mini plugins
    -- 'https://github.com/nvim-tree/nvim-web-devicons', -- if you prefer nvim-web-devicons
    'https://github.com/MeanderingProgrammer/render-markdown.nvim',
})
require('render-markdown').setup({
    render_modes = { 'n', 'c', 't' },
    code = {
        conceal_delimiters = false,
        border = 'thin',
    },
    heading = {
        backgrounds = {
            'CursorLine',
            'CursorLine',
            'CursorLine',
            'CursorLine',
            'CursorLine',
            'CursorLine',
        },
        foregrounds = {
            'Normal',
            'Normal',
            'Normal',
            'Normal',
            'Normal',
            'Normal',
        },
    },
}) -- only mandatory if you want to set custom options

local function normalize_markdown_heading_fg()
    local normal = vim.api.nvim_get_hl(0, { name = 'Normal', link = false })
    local fg = normal and normal.fg or nil
    if not fg then
        return
    end

    local groups = {
        '@markup.heading',
        '@markup.heading.1',
        '@markup.heading.2',
        '@markup.heading.3',
        '@markup.heading.4',
        '@markup.heading.5',
        '@markup.heading.6',
        '@markup.heading.1.markdown',
        '@markup.heading.2.markdown',
        '@markup.heading.3.markdown',
        '@markup.heading.4.markdown',
        '@markup.heading.5.markdown',
        '@markup.heading.6.markdown',
    }

    for _, group in ipairs(groups) do
        vim.api.nvim_set_hl(0, group, { fg = fg, bold = true })
    end
end

normalize_markdown_heading_fg()
vim.api.nvim_create_autocmd('ColorScheme', {
    callback = normalize_markdown_heading_fg,
})
