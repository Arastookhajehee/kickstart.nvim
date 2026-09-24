local function telescope(name)
  return function()
    require('lazy').load { plugins = { 'telescope.nvim' } }
    require('telescope.builtin')[name]()
  end
end

local servers = {
  marksman = {},
  clangd = {},
  gopls = {},
  pyright = {},
  arduino_language_server = {
    filetypes = { 'ino', 'arduino' },
    cmd = {
      'arduino-language-server',
      '-clangd',
      'clangd',
      '-cli',
      'arduino-cli',
      '-fqbn',
      'arduino:avr:uno',
    },
  },
  roslyn_ls = {
    filetypes = { 'cs', 'razor' },
    settings = {
      ['csharp|background_analysis'] = {
        dotnet_analyzer_diagnostics_scope = 'openFiles',
        dotnet_compiler_diagnostics_scope = 'openFiles',
      },
    },
  },
  vtsls = { settings = { vtsls = {} } },
  lua_ls = {
    on_init = function(client) client.server_capabilities.documentFormattingProvider = false end,
    settings = { Lua = { format = { enable = false } } },
  },
}

return {
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    cmd = 'LazyDev',
    opts = {
      library = { { path = '${3rd}/luv/library', words = { 'vim%.uv' } } },
    },
  },
  { 'mason-org/mason.nvim', cmd = 'Mason', opts = {} },
  {
    'j-hui/fidget.nvim',
    event = 'LspAttach',
    opts = {},
  },
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'mason-org/mason.nvim',
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          local function map(keys, func, desc, mode) vim.keymap.set(mode or 'n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc }) end

          map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
          map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          map('grr', telescope 'lsp_references', '[G]oto [R]eferences')
          map('gri', telescope 'lsp_implementations', '[G]oto [I]mplementation')
          map('grd', telescope 'lsp_definitions', '[G]oto [D]efinition')
          map('gO', telescope 'lsp_document_symbols', 'Document Symbols')
          map('gW', telescope 'lsp_dynamic_workspace_symbols', 'Workspace Symbols')
          map('grt', telescope 'lsp_type_definitions', '[G]oto [T]ype Definition')

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method('textDocument/documentHighlight', event.buf) then
            local group = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = group,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = group,
              callback = vim.lsp.buf.clear_references,
            })
            vim.api.nvim_create_autocmd('LspDetach', {
              buffer = event.buf,
              group = group,
              once = true,
              callback = function(args)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = group, buffer = args.buf }
              end,
            })
          end

          if client and client:supports_method('textDocument/inlayHint', event.buf) then
            map('<leader>th', function()
              local enabled = vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }
              vim.lsp.inlay_hint.enable(not enabled, { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      require('mason-lspconfig').setup { automatic_enable = false }
      local ensure_installed = vim.tbl_filter(function(name) return name ~= 'roslyn_ls' end, vim.tbl_keys(servers))
      vim.list_extend(ensure_installed, {
        'stylua',
        'csharpier',
        'netcoredbg',
        'roslyn-language-server',
        'prettierd',
        'prettier',
        'markdownlint',
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      for name, config in pairs(servers) do
        vim.lsp.config(name, config)
        vim.lsp.enable(name)
      end
    end,
  },
  {
    'stevearc/conform.nvim',
    cmd = 'ConformInfo',
    keys = {
      {
        '<leader>f',
        function() require('conform').format { async = true } end,
        mode = { 'n', 'v' },
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      default_format_opts = { lsp_format = 'fallback' },
      formatters_by_ft = {
        css = { 'prettierd', 'prettier', stop_after_first = true },
        html = { 'prettierd', 'prettier', stop_after_first = true },
        javascript = { 'prettierd', 'prettier', stop_after_first = true },
        javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
        json = { 'prettierd', 'prettier', stop_after_first = true },
        jsonc = { 'prettierd', 'prettier', stop_after_first = true },
        markdown = { 'prettierd', 'prettier', stop_after_first = true },
        cs = { 'csharpier' },
        typescript = { 'prettierd', 'prettier', stop_after_first = true },
        typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
        xml = { 'csharpier' },
        yaml = { 'prettierd', 'prettier', stop_after_first = true },
      },
      formatters = {
        csharpier = {
          command = 'csharpier',
          args = { 'format', '--write-stdout' },
          stdin = true,
          to_stdin = true,
        },
      },
    },
  },
}
