# focus.nvim

An asynchronous, non-blocking Pomodoro and focus tracker for Neovim, built on native `libuv` event loops (`vim.uv`). The timer runs entirely in the background — it never blocks input, redraws, or the main thread — and surfaces its state through a lightweight winbar HUD and an on-demand floating menu.

## Features

- **Non-blocking background timer** — driven by a native `libuv` timer handle; zero polling, zero input latency.
- **Winbar HUD** — a right-aligned, live-updating countdown rendered in the window bar. Any pre-existing `winbar` is saved on start and restored on stop/reset, so it never clobbers your statusline setup.
- **Floating progress menu** — a centered floating window showing the current state, remaining time, and a real-time Unicode progress bar.
- **Manual pause / resume** — explicit, predictable control via command or a buffer-local key inside the menu. No automatic focus-based pausing.
- **Skip & reset** — jump to the next phase or return the timer to a clean state at any point.
- **Configurable durations** — independent work and break lengths, expressed in minutes.

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    "zaier84/focus.nvim",
    config = function()
        require("focus").setup({
            work_duration = 25,  -- minutes
            break_duration = 5,  -- minutes
        })

        -- Global keymaps (optional)
        vim.keymap.set("n", "<leader>fs", "<cmd>FocusStart<CR>",  { desc = "Focus: Start" })
        vim.keymap.set("n", "<leader>fp", "<cmd>FocusToggle<CR>", { desc = "Focus: Pause/Resume" })
        vim.keymap.set("n", "<leader>fm", "<cmd>FocusMenu<CR>",   { desc = "Focus: Open Menu" })
    end,
}
```

### Configuration

`setup()` accepts the following options. Durations are in **minutes** and may be fractional (e.g. `0.5` = 30 seconds), which is convenient for testing.

| Option           | Type     | Default | Description                     |
| ---------------- | -------- | ------- | ------------------------------- |
| `work_duration`  | `number` | `25`   | Length of a work session (min). |
| `break_duration` | `number` | `5`   | Length of a break (min).        |

## Commands

| Command        | Description                                              |
| -------------- | ------------------------------------------------------- |
| `:FocusStart`  | Start the timer (or resume a paused session).           |
| `:FocusStop`   | Pause the timer.                                        |
| `:FocusToggle` | Toggle between paused and running.                      |
| `:FocusSkip`   | Skip to the next phase (work ⇄ break).                  |
| `:FocusReset`  | Stop and reset the timer to a clean state.              |
| `:FocusMenu`   | Open the floating progress menu.                        |

## Interactive Keymaps

### Global (suggested)

focus.nvim ships no global keymaps by default. Bind the commands as you prefer:

```lua
vim.keymap.set("n", "<leader>fs", "<cmd>FocusStart<CR>",  { desc = "Focus: Start" })
vim.keymap.set("n", "<leader>fp", "<cmd>FocusToggle<CR>", { desc = "Focus: Pause/Resume" })
vim.keymap.set("n", "<leader>fm", "<cmd>FocusMenu<CR>",   { desc = "Focus: Open Menu" })
```

### Floating menu (buffer-local)

While the floating menu is open, the following keys are mapped **only** within that buffer — they do not leak into your global keymap space:

| Key     | Action                          |
| ------- | ------------------------------- |
| `p`     | Toggle pause/resume in place.   |
| `q`     | Close the menu.                 |
| `<ESC>` | Close the menu.                 |

## Running Tests

The test suite is written with [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) (busted-style) and lives under `spec/`. With `plenary.nvim` available on your `runtimepath`, run the suite headlessly:

```sh
nvim --headless -c "PlenaryBustedDirectory spec/" -c "qa"
```

To run a single file:

```sh
nvim --headless -c "PlenaryBustedFile spec/focus/timer_spec.lua" -c "qa"
```

## Requirements

- Neovim ≥ 0.10 (uses `vim.uv`; falls back to `vim.loop` where available).
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) — for running the test suite only.
