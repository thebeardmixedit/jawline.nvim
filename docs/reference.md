# jawline.nvim reference

This reference describes the published implementation at
[`4cd18db`](https://github.com/thebeardmixedit/jawline.nvim/tree/4cd18db60ed4a21c0f1baaf3d1d635405d30fc46).
The plugin is experimental; API names and defaults may change. See the
[README](../README.md) for installation and a minimal setup.

## Public entrypoints

```lua
local jawline = require("jawline")
jawline.setup()
jawline.refresh()
local config = jawline.get_config("user")
```

- `setup(config?)` normalizes configuration, creates component instances,
  applies highlights, installs refresh handlers, sets `laststatus`, and renders
  the current window. It returns the jawline module.
- `refresh({ winid?, bufnr? }?)` renders and applies a statusline, returning the
  resulting string. The default target is the current window and its buffer.
  Explicit IDs must be valid; use the target window's buffer for matching
  metadata and cursor position.
- `get_config("default" | "normalized" | "user")` returns a copied configuration
  snapshot. With no selector it returns all three in one table. The normalized
  snapshot precedes runtime attachment; it is not the live component state.
- `:JawlineRefresh` calls refresh after setup has installed the command.

Call `setup()` to activate the plugin. A refresh before setup initializes
default rendering, but does not install handlers or set `laststatus`.

## Top-level configuration

`setup()` accepts a table with these interpreted keys:

| Key | Purpose | When omitted |
| --- | --- | --- |
| `statusline` | Content and layout | Default statusline |
| `components` | Named custom functions or component classes | No custom components |
| `theme` | Highlight overrides through `theme.groups` | No overrides |

## Statusline options and defaults

| Key | Default | Behavior |
| --- | --- | --- |
| `global` | `true` | Global statusline when true; window-local assignment when false |
| `inherit_defaults` | `false` | Fill omitted content sections from defaults |
| `spacing` | `1` | Spaces between surviving components within each section |
| `padding` | `{ left = 1, right = 1 }` | Outer line padding |
| `left` | `mode`, `filename`, `modified` | Ordered component list |
| `center` | `macro`, `search` | Ordered component list |
| `right` | `filetype`, `location` | Ordered component list |

Padding accepts a nonnegative integer for both sides, or a table with `left`
and `right`. Omitted sides use their defaults. Spacing applies equally to all
three sections; there are no section-level layout options.

When no content section is supplied, defaults are used. Supplying any content
section replaces the layout by default: omitted sections become empty.
`inherit_defaults = true` fills only omitted sections; it does not merge lists
or replace an explicitly empty list. The option is named `inherit_defaults`.

```lua
require("jawline").setup({
  statusline = {
    inherit_defaults = true,
    left = { { "filename", path = "relative" } },
    center = {},
    -- right retains its default components
  },
})
```

## Component specifications

Sections are dense, ordered lists of component names or tables:

```lua
require("jawline").setup({
  statusline = {
    left = {
      "mode",
      {
        "filename",
        path = "tail",
        padding = { left = 1, right = 0 },
        min_width = 20,
        justify = "right",
        hl = "Filename",
      },
    },
  },
})
```

The first table element is the component name. Generic controls are flat
fields on that same table:

| Field | Default | Meaning |
| --- | --- | --- |
| `enabled` | `true` | Whether to call the component |
| `padding` | `{ left = 0, right = 0 }` | Spaces inside the component |
| `min_width` | `0` | Minimum display width, including padding |
| `justify` | `"left"` | `"left"`, `"center"`, or `"right"` within minimum width |
| `preserve_min_width_when_empty` | `false` | Keep a blank slot when empty or disabled |
| `hl` | Unset | Named highlight reference or local highlight table |

Other named fields become component-specific options. Do not nest generic
controls under `layout`, or component options under `opts`. Bare functions
cannot be section items; register them by name under `components`.

String shorthand has no explicit component highlight. Default setup uses
table specifications with the named groups listed under [highlighting](#highlighting).

## Built-in components

| Name | Current output and options |
| --- | --- |
| `mode` | Mode label, or uppercase mode code when unmapped. `style` has no current effect. |
| `filename` | `path = "tail"` by default; `"full"` uses the full name and `"relative"` uses the current directory. Unnamed buffers show `[No Name]`; other path values use tail behavior. |
| `modified` | `text` (default `[+]`) when modified, otherwise empty. |
| `filetype` | Filetype text or empty. `icon` has no current effect. |
| `location` | One-based `line:column`; column is a byte position. |
| `macro` | `recording @<register>` while recording, otherwise empty. |
| `search` | Currently always empty. |

Default setup supplies `style = "block"` for mode and `icon = true` for
filetype, but the current components do not use those options.

## Custom components

Names must not conflict with built-ins. Register a function receiving
`context` and component-specific `opts`, then reference its name in a section:

```lua
require("jawline").setup({
  components = {
    label = function(context, opts)
      return opts.text or context.filetype
    end,
  },
  statusline = {
    left = { { "label", text = "editing", hl = "Accent" } },
  },
})
```

Component classes are also supported through the existing base class:

```lua
local Component = require("jawline.component")
local Label = Component:extend()

function Label:write(context)
  return self.opts.text or context.filetype
end

require("jawline").setup({
  components = { label = Label },
  statusline = { left = { { "label", text = "editing" } } },
})
```

A class must be callable to construct an instance and expose `write(context)`;
a plain table containing only a `write` function is not sufficient. The base
initializer stores `self.name` and `self.opts`. An overridden `init(spec)` must
initialize those fields if its methods need them.

Each configured occurrence has its own instance, reused across refreshes and
recreated by setup. Custom classes can retain state on the instance. There
are no component-specific refresh/event hooks. The class extension mechanism
is experimental; other reachable internal modules are not additional public
entrypoints.

## Callback context

| Fields | Meaning |
| --- | --- |
| `winid`, `bufnr` | Selected window and buffer |
| `current_winid`, `active` | Current window and whether it matches the selected window |
| `mode` | Current editor mode code |
| `filename`, `filetype`, `buftype` | Selected buffer metadata |
| `modified`, `readonly`, `modifiable` | Selected buffer flags |
| `line`, `column` | Selected window cursor position; one-based byte column |
| `total_lines` | Selected buffer line count |

## Rendering and layout

For nonempty output, rendering adds component padding, expands to minimum
display width, escapes literal `%` characters, and applies the component
highlight. Padding counts toward minimum width. Longer output is not truncated
by `min_width`; centered justification puts an odd extra space on the right.

`nil` and the empty string mean empty output. Other values are converted with
`tostring`, including `false`. Custom output is literal text: returned Neovim
statusline expressions are escaped rather than evaluated.

Empty or disabled components collapse by default, including their inter-component
spacing. With preservation enabled, their blank width is
`max(min_width, padding.left + padding.right)`. A preserved slot receives its
highlight and participates in spacing.

The renderer joins left, center, and right with two Neovim `%=` markers when
center has rendered content, or joins left and right with one marker otherwise.
A preserved blank center slot counts as content. Center placement follows
Neovim's available-space distribution, not a guaranteed geometric midpoint.
Outer line padding is added last, including when all sections are empty.

## Highlighting

Use `theme.groups` to override named groups, and `hl` to style a component:

```lua
require("jawline").setup({
  theme = {
    groups = {
      Accent = { fg = "#88c0d0", bold = true },
    },
  },
  statusline = {
    left = {
      { "mode", hl = "Accent" },
      { "filename", hl = { link = "StatusLine" } },
      { "modified", hl = { fg = "#ebcb8b", bold = true } },
    },
  },
})
```

Theme group keys and string `hl` references receive a `Jawline` prefix unless
already prefixed. Thus `hl = "Accent"` and `hl = "JawlineAccent"` refer to the
same group; `hl = "StatusLine"` refers to `JawlineStatusLine`. Use a table with
`link = "StatusLine"` to link directly to Neovim's group. Link targets are not
automatically prefixed.

Table-valued `hl` definitions create component-local groups. Generated names
are internal and should not be referenced from user configuration. Highlights
cover component padding and preserved blank slots.

| Default group | Link |
| --- | --- |
| `JawlineNormal` | `StatusLine` |
| `JawlineInactive` | `StatusLineNC` |
| `JawlineAccent` | `Directory` |
| `JawlineMuted` | `Comment` |
| `JawlineInfo` | `DiagnosticInfo` |
| `JawlineWarn` | `DiagnosticWarn` |
| `JawlineError` | `DiagnosticError` |
| `JawlineSuccess` | `DiagnosticOk` |
| `JawlineMode` | `JawlineAccent` |
| `JawlineFilename` | `JawlineNormal` |
| `JawlineModified`, `JawlineMacro` | `JawlineWarn` |
| `JawlineFiletype`, `JawlineLocation` | `JawlineMuted` |
| `JawlineSearch` | `JawlineInfo` |

Defaults are applied with Neovim's `default = true` behavior, then theme
overrides and component-local definitions are applied. Setup and `ColorScheme`
apply highlights; ordinary refresh renders with the existing groups. The
presence of `JawlineInactive` does not enable automatic inactive styling.

## Global, local, and automatic refresh

Setup sets `laststatus = 3` when `global = true`, or `laststatus = 2` otherwise.
Global refresh assigns `vim.o.statusline`; local refresh assigns the selected
window's statusline. Local mode initially refreshes the current window and
subsequently the window selected by refresh; it does not refresh every window
as a batch.

Automatic refresh events are `BufEnter`, `BufWinEnter`, `WinEnter`, `FileType`,
`ModeChanged`, `CursorMoved`, `CursorMovedI`, `TextChanged`, `TextChangedI`, and
`BufWritePost`. `ColorScheme` reapplies highlights and refreshes. Repeated setup
replaces the plugin's autocmd groups and command.

## Validation limits

Validation checks configuration table types, generic booleans, nonempty
component names, nonnegative integer layout fields, justification values, and
outer highlight/theme types. Attachment rejects unknown component names
(even when disabled) and custom names that shadow built-ins.

Validation is selective: unknown keys, dense section lists, callable class
construction, and component-specific options are not comprehensively checked.
Sections use array iteration, so gaps or named fields do not define additional
components. Highlight definition contents are passed to Neovim. Component
callback errors propagate to the caller. Configuration snapshots are copied;
callbacks retain their Lua closures.

## Architecture map

| Module | Responsibility |
| --- | --- |
| [jawline.lua](../lua/jawline.lua) | Public API, lifecycle, runtime state, commands, events, option assignment |
| [config.lua](../lua/jawline/config.lua) | Defaults and generic configuration normalization |
| [components/init.lua](../lua/jawline/components/init.lua) | Built-in/custom name resolution and instance attachment |
| [component.lua](../lua/jawline/component.lua) | Base component extension mechanism |
| [context.lua](../lua/jawline/context.lua) | Window/buffer/editor context |
| [render.lua](../lua/jawline/render.lua) | Component text and statusline assembly |
| [highlights.lua](../lua/jawline/highlights.lua) | Default/theme groups and local component highlights |

Setup prepares configuration and components; refresh creates context, renders
a string, and applies it. Built-in modules load eagerly. Statusline is the
implemented render target.

## Development and verification

From the repository root, start the
[interactive development configuration](../tests/minimal.lua) with:

```sh
nvim -u tests/minimal.lua -i NONE -n
```

This loads the plugin from the checkout and changes options, mappings,
highlights, commands, and autocmds in that process. `-i NONE` disables ShaDa
persistence and `-n` disables swap files. The leader key is Space:

- `<leader>jr`: refresh
- `<leader>js`: print the global statusline option
- `<leader>jc`: inspect context
- `<leader>jn`, `<leader>jd`, `<leader>ju`: inspect normalized, default, and user configuration
- `<leader>jx`: reload plugin modules and run default setup

This is a manual development configuration, not an assertion-based test suite.
There is no committed automated/headless runner, CI workflow, or project-level
lint/format/type-check configuration. No minimum Neovim version or compatibility
matrix is declared. Describe checks actually performed without treating this
configuration as automated coverage.

See [AGENTS.md](../AGENTS.md) for the project authority and execution workflow.
