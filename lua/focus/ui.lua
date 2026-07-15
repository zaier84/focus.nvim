local M = {}

M.buf = nil
M.win = nil
local ns_id = vim.api.nvim_create_namespace("FocusUINamespace")

function M.update_hud(time)
    local bufnr = vim.api.nvim_get_current_buf()

    vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
    vim.api.nvim_buf_set_extmark(bufnr, ns_id, 0, 0, {
        virt_text = { { time, "Comment" } },
        virt_text_pos = "right_align",
    })
end

function M.menu()
    if M.win and vim.api.nvim_win_is_valid(M.win) then
        return
    end

    M.buf = vim.api.nvim_create_buf(false, true)

    vim.api.nvim_set_option_value("buftype", "nofile", { buf = M.buf })
    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = M.buf })
    vim.api.nvim_set_option_value("swapfile", false, { buf = M.buf })

    local stats = vim.api.nvim_list_uis()[1]
    local width = 80
    local height = 9
    local col = math.floor(stats.width - width) / 2
    local row = math.floor(stats.height - height) / 2

    local win_opts = {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
    }

    M.win = vim.api.nvim_open_win(M.buf, true, win_opts)

    vim.keymap.set("n", "q", function()
        M.close_menu()
    end, { buffer = M.buf, silent = true, desc = "Close Focus Menu" })
    vim.keymap.set("n", "<ESC>", function()
        M.close_menu()
    end, { buffer = M.buf, silent = true, desc = "Close Focus Menu" })

    vim.api.nvim_create_autocmd("BufWipeout", {
        buffer = M.buf,
        callback = function()
            M.win = nil
            M.buf = nil
        end,
    })

    M.update_menu()
end

function M.update_menu()
    if M.win and vim.api.nvim_win_is_valid(M.win) and M.buf then
        local timer = require("focus.timer")
        vim.api.nvim_buf_set_lines(M.buf, 0, -1, false, {
            "STATE: " .. string.upper(timer.state),
            "TIME REMAINING: " .. timer.format_time(timer.seconds_remaining),
            M.generate_progress_bar(timer.seconds_remaining, timer.total_seconds),
        })
    end
end

function M.close_menu()
    if M.win and vim.api.nvim_win_is_valid(M.win) then
        vim.api.nvim_win_close(M.win, true)
    end
    M.win = nil
end

function M.generate_progress_bar(seconds_remaining, total_seconds)
    if not total_seconds or total_seconds == 0 then
        return "[░░░░░░░░░░░░░░░░░░░░] 0%"
    end

    local elapsed_seconds = total_seconds - seconds_remaining
    local percentage = (elapsed_seconds / total_seconds) * 100
    local filled_count = math.floor((percentage / 100) * 20)
    local empty_count = 20 - filled_count
    local blocks = string.rep("█", filled_count)
    local spaces = string.rep("░", empty_count)
    local progress_bar = "[" .. blocks .. spaces .. "] " .. math.floor(percentage) .. "%"

    return progress_bar
end

return M
