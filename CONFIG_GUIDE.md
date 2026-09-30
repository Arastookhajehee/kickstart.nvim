# Neovim Configuration Walkthrough

This document explains the current configuration, how it differs from the old
`vim.pack` setup, how to use its tools, and how to extend it without giving up
fast startup.

The configuration is still your own modular Kickstart-derived setup. It uses
`lazy.nvim` as its plugin manager, but it does **not** import LazyVim. That means
you get declarative lazy loading without inheriting a distribution's keymaps,
defaults, or opinions.

## Contents

1. [What Changed](#what-changed)
2. [Configuration Layout](#configuration-layout)
3. [How Lazy Loading Works](#how-lazy-loading-works)
4. [First Steps and Discovery](#first-steps-and-discovery)
5. [Core Editing Model](#core-editing-model)
6. [Finding and Navigating](#finding-and-navigating)
7. [Language Servers and Completion](#language-servers-and-completion)
8. [Treesitter and Structural Editing](#treesitter-and-structural-editing)
9. [Formatting, Linting, and Diagnostics](#formatting-linting-and-diagnostics)
10. [Git Workflow](#git-workflow)
11. [Debugging and Testing](#debugging-and-testing)
12. [Project-Wide Editing](#project-wide-editing)
13. [Sessions and Scratch Buffers](#sessions-and-scratch-buffers)
14. [Markdown and Research Workflow](#markdown-and-research-workflow)
15. [OpenCode Integration](#opencode-integration)
16. [Utility Tools](#utility-tools)
17. [Plugin Management](#plugin-management)
18. [Extending the Configuration](#extending-the-configuration)
19. [Environment and Dependencies](#environment-and-dependencies)
20. [Troubleshooting and Profiling](#troubleshooting-and-profiling)
21. [Key Reference](#key-reference)

## What Changed

### Before: eager `vim.pack`

The previous configuration called `vim.pack.add()` and immediately configured
most plugins from one large `init.lua`. It also scanned every file under
`lua/custom/plugins/` and required it during startup.

Opening an empty Neovim session therefore initialized systems such as:

- Telescope
- Mason and every LSP configuration
- Blink and LuaSnip
- Treesitter installation and attachment logic
- DAP and DAP UI
- Neotest
- Neo-tree
- Markdown rendering and utilities
- OpenCode and Snacks

The package manager was not inherently slow. The expensive part was activating
nearly everything before the first screen appeared.

### Now: declarative `lazy.nvim`

The new configuration describes **when** each plugin is needed:

| Trigger | Examples |
| --- | --- |
| Startup | Dracula, Mini, Snacks |
| Opening a file | LSP, Treesitter, Gitsigns |
| Entering insert mode | Blink completion, autopairs |
| Filetype | Markdown tools, LazyDev, autotag |
| Command | Mason, Telescope, Trouble, Grug Far |
| Keypress | DAP, Neotest, Harpoon, Flash, Dial |

An empty headless launch currently loads only four plugins:

- `lazy.nvim`
- `dracula.nvim`
- `mini.nvim`
- `snacks.nvim`

A measured Windows headless startup completed in roughly 94 ms. Treat that as
a local reference rather than a universal benchmark; terminal startup, disk
cache, antivirus, hardware, and platform all affect the number.

### What stayed the same

The migration preserved the specialized parts of the old configuration:

- C#, Razor, .NET debugging, and .NET tests
- Telescope-based search
- Harpoon navigation
- Markdown rendering, tables, preview, diagrams, citations, and snippets
- OpenCode integration
- Custom paragraph formatting and Visual Studio command generation
- Clipboard-focused editing behavior
- Existing DAP, Gitsigns, formatting, and diagnostic workflows

## Configuration Layout

The entrypoint is intentionally small:

```text
init.lua
```

It enables Neovim's Lua loader, sets the leaders, and imports four modules:

```lua
require 'config.options'
require 'config.keymaps'
require 'config.autocmds'
require 'config.lazy'
```

### Core files

| File | Purpose |
| --- | --- |
| `lua/config/options.lua` | Filetypes, editor options, clipboard, PowerShell |
| `lua/config/keymaps.lua` | Always-available mappings |
| `lua/config/autocmds.lua` | Diagnostics and lightweight editor autocmds |
| `lua/config/lazy.lua` | lazy.nvim bootstrap and global manager settings |
| `lua/config/snippets.lua` | Custom LuaSnip snippets |

### Plugin specifications

Every Lua file directly under `lua/plugins/` is imported automatically.

| File | Area |
| --- | --- |
| `completion.lua` | Blink, LuaSnip, snippet picker |
| `debug.lua` | DAP and Neotest |
| `editing.lua` | Surround, Dial, multicursor, Harpoon, Neo-tree |
| `lsp.lua` | LSP, Mason, LazyDev, Fidget, Conform |
| `markdown.lua` | Rendering, tables, preview, images, citations, linting |
| `telescope.lua` | Telescope, extensions, and search mappings |
| `tools.lua` | Snacks, OpenCode, Persistence, Trouble, Grug Far, Flash |
| `treesitter.lua` | Parsers, text objects, autotag |
| `ui.lua` | Theme, Mini, WhichKey, Gitsigns, indentation UI |

### Configuration modules

Larger plugin implementations remain under:

```text
lua/custom/plugins/
lua/kickstart/plugins/
```

The plugin spec owns installation and loading. Its `config` function requires
the implementation only after the trigger fires. For example:

```lua
{
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  keys = { { '<leader>ja' }, { '<leader>jl' } },
  config = function()
    require 'custom.plugins.harpoon'
  end,
}
```

This separation is useful: lifecycle metadata stays easy to scan, while a
large setup function can remain in a focused module.

## How Lazy Loading Works

`lua/config/lazy.lua` sets:

```lua
defaults = { lazy = true, version = false }
```

Plugins are lazy by default. A plugin therefore needs at least one trigger, or
it must explicitly use `lazy = false`.

### Event loading

Use events when a plugin should become available as editing begins:

```lua
{
  'lewis6991/gitsigns.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
}
```

Common choices:

| Event | Appropriate use |
| --- | --- |
| `BufReadPre` | LSP, Git, syntax-related setup before reading a file |
| `BufReadPost` | Visual helpers that can wait until the file is visible |
| `BufNewFile` | Plugins needed in new unsaved buffers |
| `InsertEnter` | Completion and insert-mode helpers |
| `VeryLazy` | Nonessential UI that can load after startup |
| `LspAttach` | Features that only matter once an LSP is active |

### Filetype loading

Use `ft` for language-specific tools:

```lua
{
  'folke/lazydev.nvim',
  ft = 'lua',
}
```

Markdown rendering does not load while editing C#. Filetype triggers can still
load earlier when another active plugin declares the same plugin as a
dependency; for example, Blink can load LazyDev outside a Lua buffer, although
LazyDev's integration remains Lua-specific.

### Command loading

Use `cmd` when a plugin provides an Ex command:

```lua
{
  'folke/trouble.nvim',
  cmd = 'Trouble',
}
```

lazy.nvim creates a temporary command. The first invocation loads the plugin
and then replays the command.

### Key loading

Use `keys` when a keypress is the natural entry point:

```lua
{
  'folke/flash.nvim',
  keys = {
    {
      'gs',
      function()
        require('flash').jump()
      end,
      mode = { 'n', 'x', 'o' },
      desc = 'Flash jump',
    },
  },
}
```

The mapping doubles as documentation and a lazy-loading trigger.

### Dependencies

Declare dependencies where they are actually required:

```lua
dependencies = {
  'nvim-lua/plenary.nvim',
  'nvim-neotest/nvim-nio',
}
```

Do not rely on another unrelated plugin to load a shared dependency first.

## First Steps and Discovery

The leader key is Space. In this guide, `<leader>sf` means press Space, then
`s`, then `f`.

### Start with these commands

| Command | Purpose |
| --- | --- |
| `:Lazy` | Plugin manager UI |
| `:Mason` | Language server and tool installer |
| `:Telescope keymaps` | Search all current mappings |
| `:checkhealth` | General diagnostics |
| `:checkhealth lazy` | Plugin manager diagnostics |
| `:checkhealth kickstart` | Local dependency checks |
| `:ConformInfo` | Formatting status for the current buffer |
| `:LspInfo` | Attached language servers |

The LSP commands become available after reading or creating a file, which loads
`nvim-lspconfig`. They are not available in a pristine empty session.

### Use WhichKey

Press Space to display available continuations and descriptions. WhichKey loads
after startup and has a zero display delay, so it provides discovery without
blocking the first frame.

### Search mappings instead of memorizing everything

Press `<leader>sk` to open Telescope's keymap picker. Type part of a description
such as `diagnostic`, `test`, `git`, or `scratch`.

### Inspect why a plugin loaded

Open `:Lazy`, move to a plugin, and inspect its load reason. This is the fastest
way to understand whether it loaded because of an event, key, command,
filetype, or dependency.

## Core Editing Model

This setup intentionally differs from stock Vim. Learn these choices before
assuming a standard mapping is broken.

### Clipboard and deletion

Yanks go to the system clipboard:

| Mapping | Action |
| --- | --- |
| `y` | Yank motion or visual selection to `+` |
| `Y` | Yank the current line to `+` |
| `X` | Cut to the system clipboard |

Destructive edits use the black-hole register:

```text
d  c  x  D  C  s  S
```

Deleting or changing text therefore does not overwrite the value you intend to
paste. Visual `p` and `P` also paste without replacing the paste register.

The `clipboard` option is set to `unnamedplus` after startup so provider
detection does not lengthen the critical startup path.

### Movement changes

| Mapping | Action |
| --- | --- |
| `j` / `k` | Move by displayed lines |
| `H` / `L` | Start/end of line |
| `Ctrl-D` / `Ctrl-U` | Half-page movement, then recenter |
| `{` / `}` | Paragraph movement, then recenter |
| `n` / `N` | Search movement, then recenter |
| Visual `J` / `K` | Move selected lines down/up |
| Normal `J` | Join while preserving cursor position |
| `U` | Redo |

### Comments

Mini Comment provides `gc`-style commenting. Visual mode also exposes:

```text
Ctrl-/
Ctrl-_
Ctrl-Shift-/
```

### Quick exits and windows

| Mapping | Action |
| --- | --- |
| Insert `ii` | Return to normal mode |
| Terminal `ii` | Leave terminal mode |
| Terminal `Esc Esc` | Leave terminal mode |
| `Ctrl-H/J/K/L` | Move between splits |
| `<leader>w` | Save |
| `Ctrl-Backtick` | Open a terminal |

Before writing a normal local file, Neovim automatically creates any missing
parent directories.

### Automatic editing helpers

- nvim-autopairs inserts matching brackets, quotes, and similar pairs.
- Guess Indent detects each buffer's indentation style.
- Indent Blankline displays indentation guides and the active scope.
- Todo Comments highlights annotations such as `TODO`, `FIX`, and `WARN`; its
  signs are disabled.
- Mini Statusline supplies the statusline.

### Text objects and surroundings

Mini AI extends standard `a` and `i` text objects. Its next-occurrence mappings
are `aa` and `ii`, and it searches up to 500 lines.

`nvim-surround` provides the familiar surround workflow:

| Example | Result |
| --- | --- |
| `ysiw"` | Surround the current word with quotes |
| `<leader>Siw"` | Surround the current word with quotes (`ys` alias) |
| `yss)` | Surround the current line with parentheses |
| `ds"` | Delete surrounding quotes |
| `cs"'` | Change double quotes to single quotes |
| Visual `<leader>S)` | Surround the visual selection |

Normal-mode `ys` remains the plugin default. `<leader>S` is an additional,
more discoverable alias: follow it with a motion or text object and then the
surrounding character. In visual mode, select text, press `<leader>S`, and then
press the surrounding character. The plugin's default visual `S` also remains
available.

Use `:help nvim-surround` for tags, function calls, aliases, and custom
surrounds.

### Paragraph formatter

The custom `mark_align` module reformats prose to a 120-column target while
handling inline Markdown-like structures and preserving cursor position.

| Mapping | Action |
| --- | --- |
| Normal `qq` | Format the current paragraph |
| Visual `qq` | Format the selected prose |

This replaces the normal meaning of `qq`, so use a different register if you
want to record macros.

## Finding and Navigating

### Telescope

Telescope is the primary picker. It normally loads through a Telescope command
or mapping, but can also load as a dependency of Harpoon, the snippet picker,
Live Preview, or Zotcite.

| Mapping | Picker |
| --- | --- |
| `<leader>sf` | Files |
| `<leader>sg` | Live grep |
| `<leader>sw` | Word or visual selection |
| `<leader>sh` | Help tags |
| `<leader>sk` | Keymaps |
| `<leader>ss` | Telescope builtins |
| `<leader>sd` | Diagnostics |
| `<leader>sr` | Resume previous picker |
| `<leader>s.` | Recent files |
| `<leader>sc` | Commands |
| `<leader><leader>` | Open buffers |
| `<leader>/` | Search current buffer |
| `<leader>s/` | Grep only open files |
| `<leader>sn` | Files in this Neovim config |
| `<leader>sq` | Quickfix list |
| `<leader>'` / `<leader>"` | Marks |

Useful picker controls:

| Mapping | Action |
| --- | --- |
| `Ctrl-N` / `Ctrl-P` | Next/previous result |
| `Enter` | Open selection |
| `Ctrl-X` | Open in horizontal split |
| `Ctrl-V` | Open in vertical split |
| `Ctrl-T` | Open in tab |
| `Ctrl-/` | Show picker mappings |

`NVIM_LAYOUT=HORIZONTAL` selects a horizontal layout. Every other value uses a
vertical layout.

Telescope FZF Native is used only when `make` exists and, on Windows, `gcc`
also exists. Telescope still works with its Lua sorter when that native build
is unavailable.

### LSP navigation

These mappings are installed only in buffers with an attached LSP:

| Mapping | Action |
| --- | --- |
| `grd` | Definitions through Telescope |
| `grr` | References through Telescope |
| `gri` | Implementations through Telescope |
| `<leader>i` | Implementations through Telescope |
| `grt` | Type definitions through Telescope |
| `<leader>T` | Type definitions through Telescope |
| `gO` | Document symbols |
| `gW` | Workspace symbols |
| `<leader>ws` | Workspace symbols through Telescope |
| `grD` | Declaration |
| `grn` | Rename |
| `gra` | Code action |

Global convenience mappings also exist:

| Mapping | Action |
| --- | --- |
| `<leader>d` | Definition, or open cursor target in Markdown |
| `<leader>D` | References |
| `<leader>R` | Rename |
| `<leader>s` | Document symbols |
| `<leader>h` | Hover documentation |
| `<leader>H` | Code action |

### Flash

Flash accelerates movement inside visible text:

| Mapping | Action |
| --- | --- |
| `gs` | Search and jump to a labeled target |
| `gS` | Treesitter-aware structural target |

Press `gs`, type enough characters to identify a target, then press its label.
Because Flash works in normal, visual, and operator-pending modes, you can use
it as the target of an edit rather than only as cursor movement.

### Harpoon

Harpoon maintains a small project-specific working set:

| Mapping | Action |
| --- | --- |
| `<leader>ja` | Add current file |
| `<leader>jl` | Show Harpoon list through Telescope |
| `<leader>jn` | Next Harpoon entry |
| `<leader>jp` | Previous Harpoon entry |
| `<leader>j1` to `<leader>j4` | Jump directly to entry 1-4 |

Use Telescope for broad discovery and Harpoon for the handful of files you are
actively changing.

### Neo-tree

Neo-tree provides filesystem, open-buffer, and Git-status sources:

| Mapping | Action |
| --- | --- |
| `\` | Reveal current file |
| `Ctrl-Shift-E` | Reveal current file |
| `<leader>eb` | Toggle buffer tree |
| `<leader>eg` | Toggle Git-status tree |

Inside Neo-tree, press `?` for the complete mapping reference. Common actions
include `a` to add, `d` to delete, `r` to rename, `H` to toggle hidden files,
and `P` to preview.

Renames and moves are passed through Snacks rename support so attached language
servers can update references when supported.

### Sequential file navigation

| Mapping | Action |
| --- | --- |
| `<leader>N` | Next file |
| `<leader>P` | Previous file |

Commands are also available:

```vim
:NextFile
:PrevFile
:NextFileSameExt
:PrevFileSameExt
```

## Language Servers and Completion

### Mason

Open `:Mason` to inspect installed tools. The LSP configuration asks Mason to
install:

| Area | Tools |
| --- | --- |
| Language servers | marksman, clangd, gopls, pyright |
| More language servers | Arduino LS, vtsls, lua_ls |
| .NET | roslyn-language-server, csharpier, netcoredbg |
| Formatting | stylua, prettierd, prettier |
| Linting | markdownlint |

`roslyn_ls` is configured as an LSP name but installed through the explicit
`roslyn-language-server` package.

After reading or creating a file, useful LSP commands include:

```vim
:Mason
:LspInfo
:LspLog
:LspRestart
```

`<leader>zig` runs `:LspRestart`, but does not itself load `nvim-lspconfig` in
an untouched empty session.

### Configured servers

| Server | Intended files |
| --- | --- |
| `marksman` | Markdown |
| `clangd` | C and C++ |
| `gopls` | Go |
| `pyright` | Python |
| `arduino_language_server` | `.ino` and Arduino buffers |
| `roslyn_ls` | C# and Razor |
| `vtsls` | JavaScript and TypeScript |
| `lua_ls` | Lua |

Roslyn background analysis is restricted to open files to keep large .NET
solutions responsive. Arduino currently targets `arduino:avr:uno`; change the
`-fqbn` value in `lua/plugins/lsp.lua` for a different board.

### LazyDev

LazyDev's LSP and completion integration is active only for attached Lua
buffers. The plugin itself can load in another filetype as a Blink dependency.
It exposes Neovim and plugin Lua types without adding every runtime file to the
LuaLS workspace.

Use:

```vim
:LazyDev
:LazyDev debug
:LazyDev lsp
```

This replaces the old broad `vim.api.nvim_get_runtime_file('', true)` approach,
which made Lua configuration editing slower.

### Fidget

Fidget loads on `LspAttach` and shows language-server progress. It is most
visible during indexing, workspace loading, and long server operations.

### Blink completion

Blink loads when insert or command-line completion can actually be used. Its
sources are:

- LazyDev module/type completion
- LSP completion
- Paths
- LuaSnip snippets
- Words from open buffers

The `super-tab` preset makes Tab the primary completion/snippet key:

| Mapping | Action |
| --- | --- |
| `Tab` | Accept selected/first item, advance snippet, or insert a tab |
| `Shift-Tab` | Move backward in a snippet or fall back |
| `Ctrl-Space` | Open completion or documentation |
| `Ctrl-N` / `Ctrl-P` | Next/previous item |
| Up / Down | Previous/next item |
| `Ctrl-B` / `Ctrl-F` | Scroll documentation |
| `Ctrl-E` | Hide completion |
| `Ctrl-K` | Toggle signature help |

Exact preset behavior comes from the installed Blink version. Run
`:help blink-cmp-config-keymap` when customizing it.

### Snippets

Friendly Snippets is loaded through LuaSnip. Four local Markdown snippets are
defined in `lua/config/snippets.lua`:

```text
mermaid-flowchart
mermaid-sequence
mermaid-class
mermaid-state
```

Use `<leader>ls` to search snippets through Telescope.

## Treesitter and Structural Editing

Treesitter loads before reading a file and attaches syntax-aware highlighting
and indentation when a parser is available.

The initial parser set includes Bash, C, C#, diff, HTML, Lua, LuaDoc, Markdown,
Markdown inline, queries, Razor, Vim, and Vimdoc. When another recognized
filetype is opened, the configuration attempts to install its parser
automatically.

### Semantic text objects

| Mapping | Object |
| --- | --- |
| `af` | Around function |
| `if` | Inside function |
| `ac` | Around class |
| `ic` | Inside class |

These work in visual and operator-pending mode. Examples:

```text
daf    delete around function
vif    select inside function
yac    yank around class
```

### Semantic movement

| Mapping | Action |
| --- | --- |
| `]m` | Next function start |
| `[m` | Previous function start |
| `]]` | Next class start |
| `[[` | Previous class start |

### Automatic closing tags

`nvim-ts-autotag` loads for HTML, XML, JSX, TSX, Vue, and Svelte. It updates
matching closing tags as you type or rename an opening tag.

### Parser maintenance

Open or create a file first so Treesitter has loaded, then run:

```vim
:TSUpdate
:checkhealth vim.treesitter
```

Treesitter is using the newer `main` branch API, so examples written for the
older `nvim-treesitter.configs.setup()` interface may not apply.

## Formatting, Linting, and Diagnostics

### Manual formatting

Press `<leader>f` in normal or visual mode. Conform formats asynchronously.

Configured formatters:

| Filetypes | Formatter order |
| --- | --- |
| Web and data files | Prettierd, then Prettier |
| C# | CSharpier |
| XML | CSharpier; verify support for your XML workflow |
| Other configured LSP buffers | LSP fallback when available |

The web and data group includes CSS, HTML, JavaScript, JSX, JSON, JSONC,
Markdown, TypeScript, TSX, and YAML.

Formatting on save is intentionally disabled. Use `:ConformInfo` to see the
formatter selected for the current buffer and whether its executable exists.

### Markdown linting

`nvim-lint` loads only for Markdown and runs `markdownlint`:

- After entering the first Markdown buffer
- On buffer write
- On leaving insert mode
- After a 100 ms debounce

### Diagnostics

Diagnostics use virtual text, severity sorting, rounded floats, and underlining
for warnings and errors.

| Mapping | Action |
| --- | --- |
| `<leader>do` | Open diagnostic float |
| `<leader>sd` | Telescope diagnostics |
| `<leader>zd` | Trouble workspace diagnostics |
| `<leader>zD` | Trouble current-buffer diagnostics |
| `<leader>q` | Telescope quickfix picker |

When an LSP supports inlay hints, `<leader>th` toggles them for that buffer.

### Trouble

Trouble provides persistent lists rather than one-shot Telescope pickers:

| Mapping | View |
| --- | --- |
| `<leader>zd` | Workspace diagnostics |
| `<leader>zD` | Current-buffer diagnostics |
| `<leader>zs` | Document symbols |
| `<leader>zl` | LSP definitions and references on the right |
| `<leader>zq` | Quickfix list |

Use Telescope when you want to pick one result quickly. Use Trouble when you
want a panel to remain open while fixing many items.

## Git Workflow

Gitsigns loads when a file is read or created.

### Navigate changes

| Mapping | Action |
| --- | --- |
| `]c` | Next hunk |
| `[c` | Previous hunk |
| `<leader>c` | Next hunk |
| `<leader>C` | Previous hunk |

### Stage and reset

| Mapping | Action |
| --- | --- |
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hS` | Stage buffer |
| `<leader>hR` | Reset buffer |
| Visual `<leader>hs` | Stage selected lines |
| Visual `<leader>hr` | Reset selected lines |

### Inspect changes

| Mapping | Action |
| --- | --- |
| `<leader>hp` | Preview hunk |
| `<leader>hi` | Inline preview |
| `<leader>hb` | Full blame for line |
| `<leader>hd` | Diff against index |
| `<leader>hD` | Diff against previous commit |
| `<leader>hq` | Current-file changes in quickfix |
| `<leader>hQ` | Repository changes in quickfix |
| `<leader>tb` | Toggle current-line blame |
| `<leader>tw` | Toggle word diff |
| `ih` | Select Git hunk as a text object |

## Debugging and Testing

### .NET debugger

DAP is key-loaded, so none of its UI or adapter setup affects normal startup.
Mason supplies `netcoredbg`.

| Mapping | Action |
| --- | --- |
| `F5` / `F8` | Start or continue |
| `F1` / `F11` | Step into |
| `F2` / `F10` | Step over |
| `F3` | Step out |
| `F9` / `<leader>b` | Toggle breakpoint |
| `<leader>B` | Conditional breakpoint |
| `<leader>dh` | Hover debug value |
| `<leader>dp` | Preview debug value |
| `<leader>dr` | Open DAP REPL |
| `<leader>dl` | Run last configuration |
| `F7` / `<leader>du` | Toggle DAP UI |

The configured C# launch modes are:

- Launch a .NET DLL selected by `ramboe-dotnet-utils`
- Attach to a local .NET process
- Attach from WSL to a Windows .NET process when the optional adapter exists

The WSL-to-Windows path requires `WIN_USERNAME`, `wslpath`, PowerShell, and the
hard-coded Scoop `netcoredbg` location in `lua/kickstart/plugins/debug.lua`.
Adjust that path if your version or installation method differs.

### Neotest

Neotest currently uses the .NET adapter:

| Mapping | Action |
| --- | --- |
| `<leader>tt` | Run nearest test |
| `<leader>tf` | Run current test file |
| `<leader>ts` | Toggle test summary |
| `<leader>to` | Open test output |
| `<leader>dt` / `F6` | Debug nearest test through DAP |

A useful .NET loop is:

1. Place the cursor inside a test.
2. Press `<leader>tt` for a normal run.
3. Open `<leader>to` if it fails.
4. Add a breakpoint with `F9`.
5. Press `F6` to rerun under the debugger.

## Project-Wide Editing

### Grug Far

Press `<leader>rg` to open project-wide search and replace with the word under
the cursor pre-filled. The mapping also works in visual mode, but it still uses
the word under the cursor rather than the selected text.

You can also run:

```vim
:GrugFar
```

Grug Far is safer than a blind project-wide substitution because it shows
matching files and allows changes to be reviewed before writing them.

### Dial

Dial performs semantic increment/decrement operations:

| Mapping | Action |
| --- | --- |
| `+` | Increment under cursor |
| `-` | Decrement under cursor |
| `g<C-a>` | Increment multiple values progressively |
| `g<C-x>` | Decrement multiple values progressively |

It understands more than numbers and can be extended with dates, booleans,
constants, and custom sequences.

### Multicursor

| Mapping | Action |
| --- | --- |
| Up / Down | Add cursor above/below |
| `<leader>`-Up / `<leader>`-Down | Skip cursor above/below |
| `<leader>mn` | Add next matching word/selection |
| `<leader>ms` | Skip next match |
| `<leader>mN` | Add previous match |
| `<leader>mS` | Skip previous match |
| Ctrl-left-click | Add/remove mouse cursor |
| Ctrl-Q | Toggle cursors |

While multiple cursors are active:

| Mapping | Action |
| --- | --- |
| Left / Right | Select previous/next main cursor |
| `<leader>x` | Delete current cursor |
| Esc | Enable disabled cursors or clear active cursors |

Because Up/Down and Ctrl-Q are repurposed after multicursor loads, use `j`/`k`
for ordinary movement and `Ctrl-V` if you prefer standard visual block mode.

## Sessions and Scratch Buffers

### Persistence

Persistence stores sessions under `stdpath('state')/sessions`.

| Mapping | Action |
| --- | --- |
| `<leader>ps` | Restore session for current directory |
| `<leader>pl` | Restore last session |
| `<leader>pd` | Stop saving the current session |

After Persistence loads on the first file read, it automatically saves a
session on exit when at least one named file buffer exists. Sessions outside
the `main` and `master` branches are branch-specific by default.

Sessions can restore buffers, tabs, splits, and working context. They complement
Harpoon: Persistence restores the workspace, while Harpoon restores your small
active file set.

### Snacks scratch buffers

| Mapping | Action |
| --- | --- |
| `<leader>ns` | Open a scratch buffer |
| `<leader>nS` | Select an existing scratch buffer |

Scratch buffers are useful for temporary notes, pasted output, or experimenting
with text without creating a project file.

Snacks also supplies:

- Big-file safeguards
- Faster initial file display
- File rename support used by Neo-tree
- Terminal windows used by OpenCode

## Markdown and Research Workflow

Markdown is one of the richest workflows in this configuration. Most of this
stack loads only for Markdown buffers.

### Render Markdown

`render-markdown.nvim` uses its Obsidian preset with custom heading, bullet,
link, code-block, and table styling. Rendering is enabled in normal, command,
and terminal modes configured by the plugin module.

Install a Nerd Font to display the configured heading icons. The
`vim.g.have_nerd_font` value in `init.lua` controls Mini icons and statusline
icons; it does not enable or disable Render Markdown's heading glyphs.

### Markdown tables

| Mapping | Action |
| --- | --- |
| `<leader>ti` | Insert table |
| `<leader>tT` | Insert table without outer pipes |
| `<leader>tc` / `<leader>tC` | Insert column right/left |
| `<leader>tr` / `<leader>tR` | Insert row below/above |
| `<leader>tj` / `<leader>tk` | Move row down/up |
| `<leader>tl` / `<leader>tH` | Move column right/left |
| `<leader>td` | Delete current column |
| Tab / Shift-Tab | Next/previous cell |

Table insertion was intentionally moved away from `<leader>tt`, which belongs
to Neotest.

### Browser preview

The preview server uses port 5500 and your default browser:

```vim
:LivePreview start
:LivePreview start path/to/file.md
:LivePreview pick
:LivePreview close
:LivePreview help
```

### Images and diagrams

Image and diagram rendering are disabled on native Windows. On Linux, WSL, or
another supported terminal environment they require:

- A Kitty-graphics-compatible terminal
- ImageMagick's `magick` command
- Mermaid tooling for Mermaid diagrams

Supported image-oriented filetypes include Markdown, Vimwiki, Typst, and Neorg.
Direct PNG, JPEG, GIF, WebP, and AVIF reads also trigger image.nvim.

Mermaid rendering uses generated CSS under Neovim's cache directory and custom
font/layout settings from `lua/custom/plugins/diagram-nvim.lua`.

### Zotero citations

Zotcite loads only when both conditions are true:

- The current file is Markdown.
- `NVIM_ZOTERO_DB_PATH` is nonempty.

Examples:

```powershell
$env:NVIM_ZOTERO_DB_PATH = 'C:/Users/you/Zotero/zotero.sqlite'
```

```bash
export NVIM_ZOTERO_DB_PATH=/mnt/c/Users/you/Zotero/zotero.sqlite
```

Use `:help zotcite` after it loads to inspect citation commands and Telescope
integration.

### Kokoro text to speech

Kokoro is disabled on Windows. It requires `rex_pcre2`, mpv, and the configured
local tool path `~/tools/kokoro_nvim`.

| Mapping | Action |
| --- | --- |
| `<leader>kk` | Read current line or visual selection |
| `<leader>kK` | Stop audio |
| `<leader><leader>kkv` | Choose voice |
| `<leader><leader>kks` | Choose speed |

If nothing happens, verify `rex_pcre2` first; the current module silently stops
configuration when that LuaRocks module cannot be loaded.

## OpenCode Integration

OpenCode communicates with a local server. Defaults:

```text
Port: 40801
URL:  http://localhost:40801
```

Override them with `OPENCODE_PORT` or `OPENCODE_URL`.

| Mapping | Action |
| --- | --- |
| `<leader>a` | Ask OpenCode about the current context |
| `<leader>x` | Open the OpenCode action selector |
| `go` | Send an operator range |
| `goo` | Send the current line |
| Ctrl-Shift-K / Ctrl-Shift-J | Scroll OpenCode up/down |
| `<leader>.` | Toggle the OpenCode server terminal |
| `<leader>A` | Attach an OpenCode terminal to the configured URL |

The configuration includes custom prompts named `tutor` and `mycommit` in
`lua/custom/plugins/opencode.lua`.

On Windows, OpenCode is launched through `cmd.exe /c`; elsewhere it is invoked
directly.

## Utility Tools

### Copy paths and references

| Mapping | Copied value |
| --- | --- |
| `<leader>yr` | Relative path from Git root |
| `<leader>yL` | Path and line |
| `<leader>ya` | Absolute path |
| Visual `<leader>ya` | Absolute path and selected range |
| `<leader>yA` | Absolute path and current line |
| `<leader>yh` | Path relative to home |
| Visual `<leader>yH` | Home-relative path and range |
| `<leader>yn` | File name |

### UUIDs

```vim
:UuidV4
:UuidToggleHighlighting
```

The plugin loads only when one of these commands is used.

### Marks

| Mapping | Action |
| --- | --- |
| `<leader>m` | Prompt for local mark `a-z` |
| `<leader>M` | Prompt for global mark `A-Z` |
| `<leader>'` / `<leader>"` | Browse marks through Telescope |

### JST timestamps

`<leader>id` inserts a timestamp in this form:

```text
YYYYMMDD-HH:MM
```

It first tries GNU `date` and falls back to Lua time arithmetic.

### Visual Studio handoff

`<leader>vs` copies a command such as this to the system clipboard:

```text
devenv /edit C:\path\to\file.cs /command "edit.goto 42"
```

The command is copied, not executed.

## Plugin Management

### Daily commands

| Command | Action |
| --- | --- |
| `:Lazy` | Open manager UI |
| `:Lazy check` | Check for updates |
| `:Lazy install` | Install missing plugins |
| `:Lazy update` | Update plugins and lockfile |
| `:Lazy sync` | Install, update, and clean |
| `:Lazy clean` | Remove plugins absent from specs |
| `:Lazy restore` | Restore revisions from lockfile |
| `:Lazy log` | Show plugin revision history |
| `:Lazy profile` | Profile startup and plugin loads |
| `:Lazy health` | Run lazy.nvim health checks |

### Lockfile

`lazy-lock.json` records exact revisions. Commit it with configuration changes.
This makes another machine install the same plugin versions.

A safe update workflow is:

1. Commit or stash current work.
2. Run `:Lazy update`.
3. Restart Neovim.
4. Test LSP, completion, Telescope, Markdown, DAP, and tests.
5. Inspect `lazy-lock.json` and commit it if everything works.
6. Run `:Lazy restore` if an update needs to be rolled back.

The old `vim.pack.update()` workflow and `nvim-pack-lock.json` are no longer the
source of truth.

## Extending the Configuration

### Add a simple plugin

Create a file under `lua/plugins/`, for example
`lua/plugins/example.lua`:

```lua
return {
  {
    'owner/plugin.nvim',
    cmd = 'PluginCommand',
    opts = {},
  },
}
```

No extra import is required. `lua/config/lazy.lua` imports the whole `plugins`
namespace.

### Pick the right trigger

| Plugin behavior | Preferred trigger |
| --- | --- |
| Used through an Ex command | `cmd` |
| Used through one or more mappings | `keys` |
| Relevant to one language | `ft` |
| Needed before reading normal files | `BufReadPre` |
| Visual enhancement after file display | `BufReadPost` |
| Insert-only behavior | `InsertEnter` |
| Absolutely required before first frame | `lazy = false` |

Avoid `lazy = false` unless the plugin affects the first rendered frame or
must establish global behavior before other plugins.

### Add a key-loaded plugin

```lua
return {
  {
    'owner/plugin.nvim',
    keys = {
      {
        '<leader>ux',
        function()
          require('plugin').toggle()
        end,
        desc = 'Toggle plugin feature',
      },
    },
    opts = {},
  },
}
```

Put the implementation directly in `keys` when it is small. Use a separate
module for a large setup.

### Separate a large configuration

Plugin spec:

```lua
{
  'owner/plugin.nvim',
  ft = 'markdown',
  config = function()
    require 'custom.plugins.plugin-name'
  end,
}
```

Implementation in `lua/custom/plugins/plugin-name.lua`:

```lua
require('plugin-name').setup {
  feature = true,
}
```

Do not put `vim.pack.add()` in the implementation. lazy.nvim must remain the
single owner of installation and runtime loading.

### Add a language server

Edit the `servers` table in `lua/plugins/lsp.lua`:

```lua
local servers = {
  rust_analyzer = {
    settings = {
      ['rust-analyzer'] = {
        check = { command = 'clippy' },
      },
    },
  },
}
```

The current installer derives most Mason package names from this table. If the
Mason package name differs from the LSP name, add the package explicitly to
`ensure_installed`.

After editing:

```vim
:Mason
:LspInfo
:checkhealth vim.lsp
```

### Add a formatter

Extend `formatters_by_ft` in `lua/plugins/lsp.lua`:

```lua
formatters_by_ft = {
  python = { 'ruff_format' },
}
```

If Mason should install it, also add its package name to `ensure_installed`.
Use `:ConformInfo` in a representative file to validate the result.

### Enable format on save

Conform currently formats manually. To enable selected filetypes, add an
`format_on_save` function to its options:

```lua
format_on_save = function(bufnr)
  local enabled = {
    lua = true,
    python = true,
  }
  if enabled[vim.bo[bufnr].filetype] then
    return { timeout_ms = 500, lsp_format = 'fallback' }
  end
end,
```

Prefer an allowlist. Enabling every formatter globally can produce unexpected
large rewrites.

### Add a Treesitter parser

Add the parser name to `parsers` in `lua/plugins/treesitter.lua`:

```lua
local parsers = {
  'lua',
  'rust',
}
```

Then run `:TSUpdate`. The automatic FileType logic can install recognized
parsers on demand, but the explicit list documents the languages you consider
part of the supported baseline.

### Add a snippet

Edit `lua/config/snippets.lua`:

```lua
ls.add_snippets('markdown', {
  ls.parser.parse_snippet(
    { trig = 'note', name = 'Note block' },
    '> [!NOTE]\n> ${1:Text}$0'
  ),
})
```

Restart Neovim or reload LuaSnip, then find it with `<leader>ls`.

### Add an always-on mapping

Place plugin-independent mappings in `lua/config/keymaps.lua`:

```lua
vim.keymap.set('n', '<leader>uc', function()
  vim.opt.cursorline = not vim.opt.cursorline:get()
end, { desc = 'Toggle cursor line' })
```

### Add a plugin mapping

Prefer the plugin spec's `keys` field. This preserves lazy loading and makes the
mapping visible in Lazy and WhichKey metadata.

### Add an LSP mapping

Add it inside the `LspAttach` callback in `lua/plugins/lsp.lua`. LSP mappings
should generally be buffer-local so they do not appear in unrelated buffers.

### Add a Gitsigns mapping

Add it inside `on_attach` in `lua/kickstart/plugins/gitsigns.lua`. Gitsigns
mappings should be local to buffers attached to a Git repository.

### Add an OS-specific plugin

Use a condition:

```lua
{
  'owner/linux-only.nvim',
  cond = function()
    return vim.env.NVIM_OS_TYPE ~= 'WIN' and vim.fn.has 'win32' == 0
  end,
}
```

Use Neovim's native platform checks as a fallback instead of depending only on
an environment variable.

### Change the colorscheme

The theme must load before the first frame:

```lua
{
  'folke/tokyonight.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    require('tokyonight').setup {}
    vim.cmd.colorscheme 'tokyonight-night'
  end,
}
```

Remove or disable the Dracula spec so two eager themes do not compete.

### Remove a plugin safely

1. Remove its spec from `lua/plugins/`.
2. Remove its custom setup module if nothing else uses it.
3. Remove mappings that call its commands or modules.
4. Check whether dependencies are shared.
5. Run `:Lazy clean` or `:Lazy sync`.
6. Test startup and commit the lockfile change.

## Environment and Dependencies

### Environment variables

| Variable | Purpose | Default |
| --- | --- | --- |
| `NVIM_OS_TYPE` | Platform override | Native detection where implemented |
| `NVIM_ZOTERO_DB_PATH` | Zotero SQLite database | Zotcite disabled |
| `NVIM_LAYOUT` | Telescope layout; `HORIZONTAL` selects horizontal | Vertical |
| `OPENCODE_PORT` | OpenCode server port | `40801` |
| `OPENCODE_URL` | OpenCode server URL | Localhost and configured port |
| `WIN_USERNAME` | WSL-to-Windows .NET attachment path | Feature unavailable |
| `NVIM_APPNAME` | Select parallel Neovim config/data directories | `nvim` |

### Baseline executables

Recommended baseline:

```text
nvim 0.12+
git
ripgrep
fd
unzip
make
C compiler
tree-sitter CLI
platform clipboard provider
```

### Language-specific requirements

| Workflow | External requirements |
| --- | --- |
| TypeScript/JavaScript | Node/npm |
| Go | Go toolchain |
| C/C++ | clangd and compiler toolchain |
| Arduino | arduino-language-server, clangd, arduino-cli, board support |
| .NET | .NET SDK/runtime, Roslyn, CSharpier, netcoredbg |
| Images | Compatible terminal and ImageMagick |
| Diagrams | Mermaid tooling |
| Kokoro | LuaRocks PCRE2 module, mpv, local Kokoro tool |
| OpenCode | `opencode` executable |

Mason handles many editor tools, but it does not install full language
toolchains such as the .NET SDK, Go, Node, or Arduino board packages.

## Troubleshooting and Profiling

### A plugin is not installed

```vim
:Lazy install
:Lazy sync
:checkhealth lazy
```

Confirm Git can reach GitHub and inspect the plugin in `:Lazy`.

### A mapping does nothing on first use

Run:

```vim
:verbose map <mapping>
```

For insert mode:

```vim
:verbose imap <mapping>
```

Then inspect the plugin's trigger in `lua/plugins/`. A plugin mapping should be
declared in `keys`, not only created after an event that may never fire.

### LSP does not attach

Open or create a file first so `nvim-lspconfig` has loaded, then run:

```vim
:LspInfo
:Mason
:checkhealth vim.lsp
:LspLog
```

Check the detected filetype:

```vim
:set filetype?
```

Also verify that the project contains the root markers expected by the server.

### Completion does not appear

1. Enter insert mode so Blink loads.
2. Press `Ctrl-Space`.
3. Run `:LspInfo` and confirm an LSP is attached.
4. Use `:Lazy` to verify Blink and LuaSnip loaded.
5. Run `:checkhealth blink.cmp` if available in the installed version.

### Formatting fails

```vim
:ConformInfo
:Mason
```

Confirm the formatter executable is installed and that the current filetype has
an entry in `formatters_by_ft`.

### Markdown features are missing

Open the Markdown file first so its plugins have loaded, then run:

```vim
:set filetype?
:Lazy
:TSUpdate
:checkhealth vim.treesitter
```

For Zotcite, inspect `NVIM_ZOTERO_DB_PATH`. For images, remember that they are
disabled on native Windows and require compatible terminal graphics.

### Debugging fails

```vim
:Mason
:lua print(vim.fn.exepath('netcoredbg'))
:checkhealth
```

Confirm the .NET project builds and produces a DLL. WSL-to-Windows attachment
has additional requirements described in the debugging section.

### Kokoro keys do nothing

Inside Neovim:

```vim
:lua print(pcall(require, 'rex_pcre2'))
```

Also verify `mpv` and `~/tools/kokoro_nvim`.

### Measure startup

Use lazy.nvim's profiler:

```vim
:Lazy profile
```

Use Neovim's startup trace from a shell:

```powershell
nvim --startuptime "$env:TEMP\nvim-startup.log" +qa
```

```bash
nvim --startuptime /tmp/nvim-startup.log +qa
```

When optimizing:

1. Inspect plugins loaded before the first screen.
2. Move nonessential plugins to `event`, `ft`, `cmd`, or `keys` triggers.
3. Test first-use latency as well as startup latency.
4. Avoid moving required setup so late that the first event has already passed.
5. Profile with both an empty launch and representative Lua, C#, and Markdown files.

The old `vim.pack` package directory may still exist under
`stdpath('data')/site/pack/core/opt`. Those packages are optional and inactive;
they can remain as a rollback cache until you are confident in the migration.

## Key Reference

### General

| Mapping | Action |
| --- | --- |
| `<leader>w` | Save |
| `Ctrl-Backtick` | Terminal |
| `<leader>f` | Format |
| `<leader>do` | Diagnostic float |
| `<leader>id` | Insert JST timestamp |
| `<leader>m/M` | Set local/global mark |
| `<leader>r` | Replace word/selection |
| `<leader>zig` | Restart LSP |

### Search and navigation

| Mapping | Action |
| --- | --- |
| `<leader>sf` | Find files |
| `<leader>sg` | Live grep |
| `<leader>sw` | Grep word/selection |
| `<leader><leader>` | Buffers |
| `<leader>/` | Search current buffer |
| `<leader>ja/jl/jn/jp` | Harpoon add/list/next/previous |
| `<leader>j1-j4` | Harpoon direct jump |
| `gs/gS` | Flash / Flash Treesitter |
| `\` | Neo-tree reveal |
| `<leader>eb/eg` | Neo-tree buffers/Git |

### LSP and diagnostics

| Mapping | Action |
| --- | --- |
| `grd/grr/gri/grt` | Definition/reference/implementation/type |
| `<leader>i` | Implementation |
| `<leader>T` | Type definition |
| `grn/gra` | Rename/code action |
| `gO/gW` | Document/workspace symbols |
| `<leader>ws` | Workspace symbols |
| `<leader>h/H` | Hover/code action |
| `<leader>th` | Inlay hints |
| `<leader>zd/zD` | Workspace/buffer diagnostics |
| `<leader>zs/zl/zq` | Symbols/LSP/quickfix Trouble views |

### Git

| Mapping | Action |
| --- | --- |
| `]c/[c` | Next/previous hunk |
| `<leader>hs/hr` | Stage/reset hunk |
| `<leader>hS/hR` | Stage/reset buffer |
| `<leader>hp/hi` | Preview hunk/inline |
| `<leader>hb` | Blame line |
| `<leader>hd/hD` | Diff index/last commit |

### Debug and test

| Mapping | Action |
| --- | --- |
| `F5/F8` | Continue |
| `F1/F11` | Step into |
| `F2/F10` | Step over |
| `F3` | Step out |
| `F9` | Breakpoint |
| `F7` | DAP UI |
| `F6` | Debug nearest test |
| `<leader>tt/tf/ts/to` | Test nearest/file/summary/output |

### Editing

| Mapping | Action |
| --- | --- |
| `+/-` | Dial increment/decrement |
| `qq` | Format paragraph/selection |
| Normal `<leader>S` | Add surroundings using a motion or text object |
| Visual `<leader>S` | Surround the selection |
| Up/Down | Add multicursor |
| `<leader>mn/ms` | Add/skip next match |
| `<leader>N/P` | Next/previous file |
| `<leader>rg` | Project replace |
| `af/if/ac/ic` | Function/class text objects |
| `]m/[m/]]/[[` | Function/class movement |

### Markdown and tools

| Mapping | Action |
| --- | --- |
| `<leader>ti` | Insert Markdown table |
| `<leader>ls` | Search snippets |
| `<leader>kk/kK` | Read/stop Kokoro |
| `<leader>ps/pl/pd` | Restore/last/disable session |
| `<leader>ns/nS` | Scratch/select scratch |
| `<leader>a/x` | Ask/select OpenCode |
| `<leader>./A` | OpenCode server/attach terminal |

The best way to learn the configuration is to use one workflow at a time,
search mappings with `<leader>sk`, and keep `:Lazy`, `:Mason`, and
`:checkhealth` close at hand.
