local geometry = require 'cursor-warp.geometry'
local platform = require 'cursor-warp.windows'

local M = {}

local defaults = {
  terminal_only = false,
  window_class = 'CASCADIA_HOSTING_WINDOW_CLASS',
  top_offset = 61,
  padding_x = 8,
  padding_y = 8,
  persist_calibration = true,
}

local opts = vim.deepcopy(defaults)
local calibration = { x = 0, y = 0 }
local commands_created = false
local state_file = vim.fn.stdpath 'state' .. '/cursor-warp.json'

local function notify(message, level) vim.notify(message, level or vim.log.levels.INFO, { title = 'cursor-warp.nvim' }) end

local function load_calibration()
  if not opts.persist_calibration or vim.fn.filereadable(state_file) ~= 1 then return end
  local ok, value = pcall(vim.json.decode, table.concat(vim.fn.readfile(state_file), '\n'))
  if ok and type(value) == 'table' then
    calibration.x = tonumber(value.x) or 0
    calibration.y = tonumber(value.y) or 0
  end
end

local function save_calibration()
  if not opts.persist_calibration then return end
  vim.fn.mkdir(vim.fn.fnamemodify(state_file, ':h'), 'p')
  vim.fn.writefile({ vim.json.encode(calibration) }, state_file)
end

local function tracked_mode()
  local mode = vim.api.nvim_get_mode().mode
  return mode == 'n' or mode == 'nt' or mode == 'v' or mode == 'V' or mode == '\22'
end

local function cursor_cell()
  local win = vim.api.nvim_get_current_win()
  local cursor = vim.api.nvim_win_get_cursor(win)
  local position = vim.fn.screenpos(win, cursor[1], cursor[2] + 1)
  if not position or position.row == 0 or position.curscol == 0 then return nil end
  return { row = position.row, col = position.curscol }
end

local function current_target()
  if not platform.available or not tracked_mode() then return nil end
  if opts.terminal_only and vim.bo.buftype ~= 'terminal' then return nil end

  local client = platform.foreground_client(opts.window_class)
  local cursor = cursor_cell()
  if not client or not cursor then return nil end

  return geometry.target(client, { columns = vim.o.columns, lines = vim.o.lines }, cursor, opts, calibration)
end

function M.warp()
  local target = current_target()
  if not target then return end

  -- Keep the pointer over OpenCode's chat area when the cursor is lower in the terminal.
  local shift_up = target.y < 200 and 0 or 150
  platform.set_cursor_position(target.x, target.y - shift_up)
end

function M.calibrate()
  local target = current_target()
  local pointer = platform.cursor_position()
  if not target or not pointer then
    notify('Calibration requires the Neovim Windows Terminal window to be focused', vim.log.levels.WARN)
    return
  end

  calibration.x = calibration.x + pointer.x - target.x
  calibration.y = calibration.y + pointer.y - target.y
  save_calibration()
  notify(('Calibrated offset: x=%d, y=%d'):format(calibration.x, calibration.y))
end

function M.reset_calibration()
  calibration = { x = 0, y = 0 }
  save_calibration()
  notify 'Calibration reset'
end

function M.status() notify(('available=%s, terminal_only=%s, offset=(%d,%d)'):format(platform.available, opts.terminal_only, calibration.x, calibration.y)) end

local function create_commands()
  if commands_created then return end
  commands_created = true
  vim.api.nvim_create_user_command('CursorWarpNow', M.warp, {})
  vim.api.nvim_create_user_command('CursorWarpCalibrate', M.calibrate, {})
  vim.api.nvim_create_user_command('CursorWarpResetCalibration', M.reset_calibration, {})
  vim.api.nvim_create_user_command('CursorWarpStatus', M.status, {})
end

function M.setup(config)
  opts = vim.tbl_deep_extend('force', vim.deepcopy(defaults), config or {})
  load_calibration()
  create_commands()
end

return M
