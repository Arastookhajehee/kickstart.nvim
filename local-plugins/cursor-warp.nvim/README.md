# cursor-warp.nvim

`cursor-warp.nvim` moves the Windows mouse pointer to Neovim's rendered cursor after Normal or Visual mode motions. It is designed for a single Neovim instance filling one Windows Terminal pane, including Neovim-managed splits and terminal buffers.

The plugin is Windows-specific and calls `user32.dll` directly through Neovim's bundled LuaJIT FFI.

## Configuration

```lua
require('cursor-warp').setup {
  enabled = true,
  terminal_only = false,
  window_class = 'CASCADIA_HOSTING_WINDOW_CLASS',
  top_offset = 61,
  padding_x = 8,
  padding_y = 8,
  persist_calibration = true,
}
```

`top_offset` accounts for the Windows Terminal title and tab bar. The defaults match the local Windows Terminal layout for which this plugin was created.

## Commands

- `:CursorWarpEnable`
- `:CursorWarpDisable`
- `:CursorWarpToggle`
- `:CursorWarpNow`
- `:CursorWarpStatus`
- `:CursorWarpCalibrate`
- `:CursorWarpResetCalibration`

To calibrate, put the Neovim cursor somewhere visible, place the mouse pointer over that cursor without making another Neovim motion, and run `:CursorWarpCalibrate`. The correction is saved under `stdpath('state')` by default.

Windows Terminal panes outside Neovim are not supported. Use one Windows Terminal pane and create splits inside Neovim.
