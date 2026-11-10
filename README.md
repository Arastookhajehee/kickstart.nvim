# Neovim configuration

Personal Neovim 0.12+ configuration derived from
[kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim). It uses
[lazy.nvim](https://github.com/folke/lazy.nvim) for plugin management without
using the LazyVim distribution.

## Highlights

- LSP servers and developer tools managed through Mason
- Blink completion with LuaSnip snippets
- Treesitter highlighting and text objects
- Telescope search and project navigation
- .NET debugging and testing
- Git, Markdown, formatting, linting, and OpenCode integrations
- Local plugins for manual cursor positioning and repository-wide Git status

See [CONFIG_GUIDE.md](CONFIG_GUIDE.md) for the full configuration walkthrough,
keymap reference, dependencies, and troubleshooting steps. Optional environment
variables are documented in [ENV_VARS.md](ENV_VARS.md).

## Layout

```text
init.lua                 Entry point
lua/config/              Editor options, mappings, autocmds, and lazy.nvim
lua/plugins/             Declarative plugin specifications
lua/custom/plugins/      Focused plugin configuration modules
lua/kickstart/plugins/   Retained Kickstart-derived configuration modules
local-plugins/           Plugins maintained with this configuration
lazy-lock.json           Reproducible plugin revisions
```

## Plugin management

Run `:Lazy` to inspect plugins. A safe update workflow is:

1. Commit or stash current work.
2. Run `:Lazy update`.
3. Restart Neovim and test the affected workflows.
4. Review and commit `lazy-lock.json`.

Use `:Lazy restore` to restore the revisions recorded in the lockfile.

## Lightweight OpenCode editor

Set `NVIM_PROFILE=opencode-editor` to start Neovim with the regular editor
options and remaps but only Flash navigation (`gs`), Markdownlint diagnostics,
Markdown table editing, and the built-in paragraph formatter (`qq`). This
profile does not load the full UI, LSP, completion, or Markdown rendering plugins.
The normal `nvim` command still uses the full profile when the variable is unset.

In PowerShell, launch OpenCode with the profile inherited by its `/editor` command:

```powershell
$env:NVIM_PROFILE = 'opencode-editor'
$env:VISUAL = 'nvim'
opencode
```

OpenCode's `/editor` (or Ctrl+X, then E) opens the current prompt in Neovim;
save and quit to return it to the composer. To edit another file with the same
profile, run `nvim notes.md` in that shell. Use a separate shell without
`NVIM_PROFILE` for the full config, or run
`Remove-Item Env:NVIM_PROFILE` to restore it in the current shell.
Markdownlint requires the `markdownlint` executable on your PATH.

## Basic requirements

- Neovim 0.12 or newer
- Git and ripgrep
- A C compiler and `make` for native extensions
- `fd`, `unzip`, and the Tree-sitter CLI
- Language runtimes and SDKs for the tools you use

Run `:checkhealth` and `:checkhealth kickstart` for local diagnostics.
