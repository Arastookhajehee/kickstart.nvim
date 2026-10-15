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

## Basic requirements

- Neovim 0.12 or newer
- Git and ripgrep
- A C compiler and `make` for native extensions
- `fd`, `unzip`, and the Tree-sitter CLI
- Language runtimes and SDKs for the tools you use

Run `:checkhealth` and `:checkhealth kickstart` for local diagnostics.
