local function builtin(name, opts)
  return function() require('telescope.builtin')[name](opts or {}) end
end

return {
  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-ui-select.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function() return vim.fn.executable 'make' == 1 and (vim.fn.has 'win32' == 0 or vim.fn.executable 'gcc' == 1) end,
      },
    },
    keys = {
      { '<leader>sh', builtin 'help_tags', desc = '[S]earch [H]elp' },
      { '<leader>sk', builtin 'keymaps', desc = '[S]earch [K]eymaps' },
      { '<leader>sf', builtin 'find_files', desc = '[S]earch [F]iles' },
      { '<leader>ss', builtin 'builtin', desc = '[S]earch [S]elect Telescope' },
      { '<leader>sw', builtin 'grep_string', mode = { 'n', 'v' }, desc = '[S]earch current [W]ord' },
      { '<leader>sg', builtin 'live_grep', desc = '[S]earch by [G]rep' },
      { '<leader>sd', builtin 'diagnostics', desc = '[S]earch [D]iagnostics' },
      { '<leader>sr', builtin 'resume', desc = '[S]earch [R]esume' },
      { '<leader>s.', builtin 'oldfiles', desc = '[S]earch recent files' },
      { '<leader>sc', builtin 'commands', desc = '[S]earch [C]ommands' },
      { '<leader><leader>', builtin 'buffers', desc = 'Find existing buffers' },
      {
        '<leader>/',
        function()
          require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
            winblend = 10,
            previewer = false,
          })
        end,
        desc = 'Fuzzily search current buffer',
      },
      { '<leader>s/', builtin('live_grep', { grep_open_files = true, prompt_title = 'Live Grep in Open Files' }), desc = '[S]earch open files' },
      {
        '<leader>sn',
        function() require('telescope.builtin').find_files { cwd = vim.fn.stdpath 'config', follow = true } end,
        desc = '[S]earch [N]eovim files',
      },
      {
        '<leader>d',
        function()
          if vim.bo.filetype == 'markdown' then
            local target = vim.fn.expand '<cfile>'
            if target ~= '' and vim.ui.open then
              vim.ui.open(target)
              return
            end
          end
          require('telescope.builtin').lsp_definitions()
        end,
        desc = 'Go to definition',
      },
      { '<leader>D', builtin 'lsp_references', desc = 'Go to references' },
      { '<leader>i', builtin 'lsp_implementations', desc = 'Go to implementation' },
      { '<leader>T', builtin 'lsp_type_definitions', desc = 'Go to Type Definition' },
      { '<leader>R', vim.lsp.buf.rename, desc = 'Rename symbol' },
      { '<leader>q', builtin 'quickfix', desc = 'Quickfix picker' },
      { '<leader>sq', builtin 'quickfix', desc = '[S]earch [Q]uickfix' },
      { '<leader>g', builtin 'live_grep', desc = 'Search text' },
      { '<leader>s', builtin 'lsp_document_symbols', desc = 'Document symbols' },
      { '<leader>ws', builtin 'lsp_dynamic_workspace_symbols', desc = 'Workspace symbols' },
      { "<leader>'", builtin 'marks', desc = 'List marks' },
      { '<leader>"', builtin 'marks', desc = 'List all marks' },
    },
    config = function()
      local layout = vim.env.NVIM_LAYOUT == 'HORIZONTAL' and 'horizontal' or 'vertical'
      require('telescope').setup {
        defaults = { layout_strategy = layout, layout_config = { vertical = { preview_height = 0.5 } } },
        extensions = { ['ui-select'] = { require('telescope.themes').get_dropdown() } },
      }
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')
    end,
  },
}
