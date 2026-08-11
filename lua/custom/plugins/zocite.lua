vim.pack.add({
  "https://github.com/nvim-telescope/telescope.nvim",
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/jalvesaq/zotcite",
})

require('nvim-treesitter').setup {}

local path = vim.env.NVIM_ZOTERO_DB_PATH
if not path or path == '' then return end

require('zotcite').setup {
  zotero_sqlite_path = path,
  -- key_type = 'template', -- 'template' | 'better-bibtex' | 'zotero'
}
