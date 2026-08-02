-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

vim.pack.add {
  'https://github.com/mfussenegger/nvim-dap',
  'https://github.com/rcarriga/nvim-dap-ui',
  'https://github.com/nvim-neotest/nvim-nio',
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/jay-babu/mason-nvim-dap.nvim',
  'https://github.com/ramboe/ramboe-dotnet-utils',
  -- 'https://github.com/leoluz/nvim-dap-go',
}

-- Basic debugging keymaps, feel free to change to your liking!
vim.keymap.set('n', '<F5>', function() require('dap').continue() end, { desc = 'Debug: Start/Continue' })
vim.keymap.set('n', '<F8>', function() require('dap').continue() end, { desc = 'Debug: Start/Continue' })
vim.keymap.set('n', '<F1>', function() require('dap').step_into() end, { desc = 'Debug: Step Into' })
vim.keymap.set('n', '<F11>', function() require('dap').step_into() end, { desc = 'Debug: Step Into' })
vim.keymap.set('n', '<F2>', function() require('dap').step_over() end, { desc = 'Debug: Step Over' })
vim.keymap.set('n', '<F10>', function() require('dap').step_over() end, { desc = 'Debug: Step Over' })
vim.keymap.set('n', '<F3>', function() require('dap').step_out() end, { desc = 'Debug: Step Out' })
vim.keymap.set('n', '<leader>b', function() require('dap').toggle_breakpoint() end, { desc = 'Debug: Toggle Breakpoint' })
vim.keymap.set('n', '<F9>', function() require('dap').toggle_breakpoint() end, { desc = 'Debug: Toggle Breakpoint' })
vim.keymap.set('n', '<leader>B', function() require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, { desc = 'Debug: Set Breakpoint' })
vim.keymap.set({ 'n', 'v' }, '<leader>dh', function() require('dap.ui.widgets').hover() end, { desc = 'Debug: Hover Value' })
vim.keymap.set({ 'n', 'v' }, '<leader>dp', function() require('dap.ui.widgets').preview() end, { desc = 'Debug: Preview Value' })
vim.keymap.set('n', '<leader>dr', function() require('dap').repl.open() end, { desc = 'Debug: Open REPL' })
vim.keymap.set('n', '<leader>dl', function() require('dap').run_last() end, { desc = 'Debug: Run Last' })
-- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
vim.keymap.set('n', '<F7>', function() require('dapui').toggle() end, { desc = 'Debug: See last session result.' })
vim.keymap.set('n', '<leader>du', function() require('dapui').toggle() end, { desc = 'Debug: Toggle UI' })

local dap = require 'dap'
local dapui = require 'dapui'

require('mason-nvim-dap').setup {
  -- Makes a best effort to setup the various debuggers with
  -- reasonable debug configurations
  automatic_installation = true,

  -- You can provide additional configuration to the handlers,
  -- see mason-nvim-dap README for more information
  handlers = {},

  -- You'll need to check that you have the required things installed
  -- online, please don't ask me how to install them :)
  ensure_installed = {
    -- Update this to ensure that you have the debuggers for the langs you want
    -- 'delve',
    'netcoredbg',
  },
}

local netcoredbg_path = vim.fn.stdpath 'data' .. '/mason/packages/netcoredbg/netcoredbg'
local netcoredbg_adapter = {
  type = 'executable',
  command = netcoredbg_path,
  args = { '--interpreter=vscode' },
}

dap.adapters.netcoredbg = netcoredbg_adapter
dap.adapters.coreclr = netcoredbg_adapter

local windows_netcoredbg_path = vim.env.WIN_USERNAME and ('/mnt/c/Users/' .. vim.env.WIN_USERNAME .. '/scoop/apps/netcoredbg/3.2.0-1092/netcoredbg.exe')

local function wslpath_to_windows(path)
  local result = vim.system({ 'wslpath', '-w', path }, { text = true }):wait()
  if result.code ~= 0 then return nil end
  return vim.trim(result.stdout)
end

local function windows_source_file_map()
  local wsl_cwd = vim.fn.getcwd()
  local windows_cwd = wslpath_to_windows(wsl_cwd)
  if not windows_cwd or windows_cwd == '' then return nil end
  return { [windows_cwd] = wsl_cwd }
end

local function get_windows_processes()
  local result = vim.system({
    'powershell.exe',
    '-NoProfile',
    '-Command',
    [[Get-Process | Where-Object { $_.Path } | Select-Object Id,ProcessName,Path | Sort-Object ProcessName,Id | ConvertTo-Json -Compress]],
  }, { text = true }):wait()

  if result.code ~= 0 or result.stdout == '' then return nil end

  local ok, processes = pcall(vim.json.decode, result.stdout)
  if not ok or not processes then return nil end
  if processes.Id then return { processes } end
  return processes
end

local function pick_windows_process()
  local dap_abort = require('dap').ABORT
  local processes = get_windows_processes()
  if not processes or vim.tbl_isempty(processes) then
    vim.notify('No Windows processes found.', vim.log.levels.ERROR)
    return dap_abort
  end

  return coroutine.create(function(dap_run_co)
    vim.ui.select(processes, {
      prompt = 'Attach to Windows process',
      format_item = function(process)
        return ('%s  %s  %s'):format(process.Id, process.ProcessName, process.Path or '')
      end,
    }, function(choice) coroutine.resume(dap_run_co, choice and choice.Id or dap_abort) end)
  end)
end

if windows_netcoredbg_path and vim.fn.executable(windows_netcoredbg_path) == 1 then
  dap.adapters.coreclr_windows = {
    type = 'executable',
    command = windows_netcoredbg_path,
    args = { '--interpreter=vscode' },
  }
end

dap.configurations.cs = {
  {
    type = 'coreclr',
    name = 'Launch .NET DLL',
    request = 'launch',
    program = function() return require('dap-dll-autopicker').build_dll_path() end,
  },
  {
    type = 'coreclr',
    name = 'Attach to .NET process',
    request = 'attach',
    processId = function() return require('dap.utils').pick_process() end,
  },
  {
    type = 'coreclr_windows',
    name = 'Attach to Windows .NET process',
    request = 'attach',
    processId = pick_windows_process,
    justMyCode = false,
    requireExactSource = false,
    suppressJITOptimizations = true,
    sourceFileMap = windows_source_file_map,
  },
}

-- Dap UI setup
-- For more information, see |:help nvim-dap-ui|
---@diagnostic disable-next-line: missing-fields
dapui.setup {
  -- Set icons to characters that are more likely to work in every terminal.
  --    Feel free to remove or use ones that you like more! :)
  --    Don't feel like these are good choices.
  icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
  ---@diagnostic disable-next-line: missing-fields
  controls = {
    icons = {
      pause = '⏸',
      play = '▶',
      step_into = '⏎',
      step_over = '⏭',
      step_out = '⏮',
      step_back = 'b',
      run_last = '▶▶',
      terminate = '⏹',
      disconnect = '⏏',
    },
  },
}

-- Debug signs shown in the sign column while using nvim-dap.
local function setup_dap_signs()
  vim.api.nvim_set_hl(0, 'DapBreakpoint', { fg = '#d06f79' })
  vim.api.nvim_set_hl(0, 'DapStopped', { fg = '#00d75f' })
  vim.api.nvim_set_hl(0, 'DapBreakpointCondition', { fg = '#ffcc00' })
  vim.api.nvim_set_hl(0, 'DapLogPoint', { fg = '#61afef' })
  vim.api.nvim_set_hl(0, 'DapBreakpointRejected', { fg = '#ff8800' })
  vim.api.nvim_set_hl(0, 'DapStoppedLine', { bg = '#1f3d2b' })

  vim.fn.sign_define('DapBreakpoint', { text = '●', texthl = 'DapBreakpoint', numhl = 'DapBreakpoint' })
  vim.fn.sign_define('DapStopped', { text = '➜', texthl = 'DapStopped', numhl = 'DapStopped', linehl = 'DapStoppedLine' })
  vim.fn.sign_define('DapBreakpointCondition', { text = '◆', texthl = 'DapBreakpointCondition', numhl = 'DapBreakpointCondition' })
  vim.fn.sign_define('DapLogPoint', { text = '◆', texthl = 'DapLogPoint', numhl = 'DapLogPoint' })
  vim.fn.sign_define('DapBreakpointRejected', { text = '✖', texthl = 'DapBreakpointRejected', numhl = 'DapBreakpointRejected' })
end

setup_dap_signs()
vim.api.nvim_create_autocmd('ColorScheme', { callback = setup_dap_signs })

dap.listeners.after.event_initialized['dapui_config'] = dapui.open
dap.listeners.before.event_terminated['dapui_config'] = dapui.close
dap.listeners.before.event_exited['dapui_config'] = dapui.close

-- Install golang specific config
-- require('dap-go').setup {
--   delve = {
--     -- On Windows delve must be run attached or it crashes.
--     -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
--     detached = vim.fn.has 'win32' == 0,
--   },
-- }
