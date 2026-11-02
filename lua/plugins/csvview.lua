return {
  {
    'hat0uma/csvview.nvim',
    cmd = { 'CsvViewEnable', 'CsvViewDisable', 'CsvViewToggle', 'CsvViewInfo' },
    init = function()
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'csv',
        callback = function(args)
          vim.api.nvim_buf_call(args.buf, function() vim.cmd 'CsvViewEnable' end)
        end,
      })
    end,
    opts = { view = { display_mode = 'border' } },
  },
}
