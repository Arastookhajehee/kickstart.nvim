local function select_object(query)
  return function() require('nvim-treesitter-textobjects.select').select_textobject(query, 'textobjects') end
end

local function move(method, query)
  return function() require('nvim-treesitter-textobjects.move')[method](query, 'textobjects') end
end

return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    event = { 'BufReadPre', 'BufNewFile' },
    build = ':TSUpdate',
    config = function()
      local treesitter = require 'nvim-treesitter'
      local parsers = { 'bash', 'c', 'c_sharp', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'razor', 'vim', 'vimdoc' }
      treesitter.install(parsers)

      local available = treesitter.get_available()
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('treesitter-attach', { clear = true }),
        callback = function(args)
          local language = vim.treesitter.language.get_lang(args.match)
          if not language then return end
          local function attach()
            if not vim.treesitter.language.add(language) then return end
            vim.treesitter.start(args.buf, language)
            if vim.treesitter.query.get(language, 'indents') then vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" end
          end
          if vim.tbl_contains(treesitter.get_installed 'parsers', language) then
            attach()
          elseif vim.tbl_contains(available, language) then
            treesitter.install(language):await(attach)
          else
            attach()
          end
        end,
      })
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = {
      select = {
        lookahead = true,
        selection_modes = { ['@parameter.outer'] = 'v', ['@function.outer'] = 'V', ['@class.outer'] = 'V' },
      },
      move = { set_jumps = true },
    },
    keys = {
      { 'af', select_object '@function.outer', mode = { 'x', 'o' }, desc = 'Around function' },
      { 'if', select_object '@function.inner', mode = { 'x', 'o' }, desc = 'Inside function' },
      { 'ac', select_object '@class.outer', mode = { 'x', 'o' }, desc = 'Around class' },
      { 'ic', select_object '@class.inner', mode = { 'x', 'o' }, desc = 'Inside class' },
      { ']m', move('goto_next_start', '@function.outer'), mode = { 'n', 'x', 'o' }, desc = 'Next function' },
      { '[m', move('goto_previous_start', '@function.outer'), mode = { 'n', 'x', 'o' }, desc = 'Previous function' },
      { ']]', move('goto_next_start', '@class.outer'), mode = { 'n', 'x', 'o' }, desc = 'Next class' },
      { '[[', move('goto_previous_start', '@class.outer'), mode = { 'n', 'x', 'o' }, desc = 'Previous class' },
    },
  },
  {
    'windwp/nvim-ts-autotag',
    ft = { 'html', 'xml', 'javascriptreact', 'typescriptreact', 'vue', 'svelte' },
    opts = {},
  },
}
