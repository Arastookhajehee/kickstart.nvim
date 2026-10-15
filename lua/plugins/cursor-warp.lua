return {
  {
    dir = vim.fn.stdpath 'config' .. '/local-plugins/cursor-warp.nvim',
    name = 'cursor-warp.nvim',
    cmd = { 'CursorWarpNow', 'CursorWarpCalibrate', 'CursorWarpResetCalibration', 'CursorWarpStatus' },
    opts = {},
  },
}
