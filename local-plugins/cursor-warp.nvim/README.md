# cursor-warp.nvim

`cursor-warp.nvim` manually moves the Windows mouse pointer to Neovim's
rendered cursor. It does not register movement, mode, window, or buffer
autocommands and therefore never moves the pointer automatically.

The plugin is Windows-specific and calls `user32.dll` through Neovim's bundled
LuaJIT FFI. It is lazy-loaded when one of its commands is used.

## Commands

- `:CursorWarpNow` moves the pointer once.
- `:CursorWarpCalibrate` calculates and saves an offset from the pointer's
  current position.
- `:CursorWarpResetCalibration` resets the saved offset.
- `:CursorWarpStatus` reports platform availability and calibration state.

To calibrate, place Neovim's cursor somewhere visible, place the mouse pointer
over that cursor, and run `:CursorWarpCalibrate`. The correction is saved under
`stdpath('state')`.

The default geometry values target a single Neovim instance filling a Windows
Terminal pane. Panes outside Neovim are not supported; use Neovim-managed
splits instead.
