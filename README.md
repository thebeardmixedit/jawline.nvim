# jawline.nvim

A sharp little Neovim statusline with a clean jaw and no extra chin.

> Experimental. APIs and defaults may change.

In active development. Not recommended for production use yet.

## Installation and setup

Install `thebeardmixedit/jawline.nvim` with your plugin manager. For example,
add this specification to an existing lazy.nvim configuration:

```lua
{
  "thebeardmixedit/jawline.nvim",
  config = function()
    require("jawline").setup()
  end,
}
```

For another installation method, make the plugin available on Neovim's
`runtimepath`, then call `require("jawline").setup()`.

Default setup provides a global statusline with mode, filename, modified
indicator, macro recording, filetype, and cursor location. The registered
`search` component currently produces no output.

## Configuration

To choose your own content, replace the setup call above with:

```lua
require("jawline").setup({
  statusline = {
    left = { "mode", { "filename", path = "relative" } },
    center = { "macro" },
    right = { "location" },
  },
})
```

Supplying any of `left`, `center`, or `right` replaces the default layout;
omitted sections become empty. Set `statusline.inherit_defaults = true` to
fill omitted sections from defaults. Explicitly empty sections stay empty.
Changing only an option such as `statusline.global` keeps the default layout.

Register named custom functions or component classes through `components`.
Style components with `hl`, and override named highlight groups through
`theme.groups`.

See the [reference](docs/reference.md) for the current API, components, layout,
and highlighting behavior. The [development configuration](tests/minimal.lua)
provides interactive refresh and inspection controls; it is not an automated
test suite.
