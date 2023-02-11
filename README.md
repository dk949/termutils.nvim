# termutils.nvim

Some basic terminal utilities for neovim.

## Installation

Install like you would any other plugin, then run the `setup` function

**packer.nvim:**

```lua
use {
    "dk949/termutils.nvim",
    config = function()
        require('termutils').setup();
    end
}
```

**vim plug:**

```vim
Plug "dk949/termutils.nvim"
...
lua << EOF
    require('termutils').setup();
EOF
```


## Features

* `startTerminal(orientation?:Orientation)`
  * Open a new terminal in a new window
  * Optionally automatically enter insert mode
  * Orientation can be one of
    * `Orientation.VERT`
    * `Orientation.HORIZ`
    * `Orientation.AUTO`
      * `AUTO` will determine the best orientation to open the terminal in
* `smartClose()`
  * If the current window had a terminal on it, close current buffer and return
  to the terminal.
  * Otherwise close the window as if by `:x`.
  * Useful when opening new buffers with [nvr](https://github.com/mhinz/neovim-remote).
    * When the buffer opened by nvr is closed, control is returned to the
    terminal.

## Configuration

The setup function optionally accepts a list of options. Any option not set in
the setup function retains it's default value

| Option               | Default              | Description                                                              |
| -------------------- | -------------------- | -----------                                                              |
| `removeNumbers`      | `true`               | Remove line numbers in the terminal buffer                               |
| `startinsert`        | `true`               | Start insert mode when entering terminal buffer                          |
| `smartClose`         | `true`               | Enable smart close (see above)                                           |
| `defaultOrientation` | `Orientation.AUTO`   | Default orientation for a new terminal                                   |
| `charRatio`          | `0.5`                | Ratio of a character's height to its width. Used for `Orientation.AUTO`. |
