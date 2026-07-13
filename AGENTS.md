# Repository Notes

## Shape
- This is a personal Neovim config forked from `kickstart.nvim`, but the active config is not stock Kickstart.
- `init.lua` is the main entrypoint and uses Neovim 0.12+ built-in `vim.pack`; do not assume `lazy.nvim` manages current plugins.
- `init.lua` explicitly requires the example modules in `lua/kickstart/plugins/` and then `require 'custom.plugins'`; those example files are active, not dormant templates.
- `lua/custom/plugins/init.lua` auto-requires every `*.lua` file in `lua/custom/plugins/` except itself, so adding a file there enables it on startup.
- `after/plugin/*.lua` runs after startup and can add plugins or override earlier settings/keymaps; check it before treating `init.lua` as final.

## Commands
- Format/check Lua with `stylua --check .`; there is no repo-local task runner or CI workflow in this checkout.
- Local `stylua` may not be installed; install it before relying on the format check.
- Verify the config with `nvim --headless '+checkhealth kickstart' '+qa'` when plugin/runtime changes are relevant.
- Inspect pending `vim.pack` plugin updates inside Neovim with `:lua vim.pack.update(nil, { offline = true })`; fetch/apply updates with `:lua vim.pack.update()` then write the update buffer.

## Plugin State
- `lazy-lock.json` is tracked but the active config uses `vim.pack`, so do not update it for normal plugin changes unless reintroducing Lazy explicitly.
- `nvim-pack-lock.json` reflects `vim.pack` state but is ignored by `.gitignore` in this checkout; do not assume changes to it will be committed.
- `PackChanged` build hooks in `init.lua` run `make` for `telescope-fzf-native.nvim`, `make install_jsregexp` for `LuaSnip` on non-Windows, and `TSUpdate` for `nvim-treesitter`.

## Local Assumptions
- `kickstart.health` expects Neovim latest stable/nightly and checks for `git`, `make`, `unzip`, and `rg`.
- Zotero citation support in `lua/custom/plugins/zocite.lua` builds `/mnt/c/Users/$WIN_USERNAME/Zotero/zotero.sqlite`; guard or preserve that WSL-specific assumption when editing it.
- Image and diagram plugins use the Kitty graphics backend, `magick_cli`, and Mermaid CLI options; changes may depend on the user's terminal and external binaries.
- `kokoro.nvim` only configures if `rex_pcre2` can be loaded from local LuaRocks paths and expects `~/tools/kokoro_nvim` plus `mpv`.

## Style
- Lua formatting follows `.stylua.toml`: 2-space indents, Unix line endings, 160-column width, auto-prefer single quotes, no call parentheses when allowed.
- Existing custom plugin files are not uniformly formatted; prefer running Stylua on touched Lua rather than preserving inconsistent whitespace.
- Do not infer options/keymaps from `init.lua` alone: `after/plugin/user-remaps.lua` changes clipboard behavior, relative numbers, indentation width, wrapping, and many normal-mode editing keys.
