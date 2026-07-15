local M = {}

function M.setup(opts)
    M.config = opts
    M.seconds_remaining = nil
    M.state = nil
    M.isPaused = nil
    M.handle = nil
end

function M.start()
    if not M.config then
        vim.notify("focus.nvim: call require('focus').setup() first", vim.log.levels.ERROR)
        return
    end
    if M.state == nil then
        M.state = "work"
        M.total_seconds = M.config.work_duration * 60
    end
    if not M.seconds_remaining then
        M.seconds_remaining = M.config.work_duration * 60
    end

    if M.handle then
        M.handle:close()
        M.handle = nil
    end
    if M.handle == nil then
        local uv = vim.uv or vim.loop
        M.handle = uv.new_timer()
    end
    M.isPaused = false
    local suffix = (M.state == "break") and " (Break Time)" or ""
    require("focus.ui").hud_text = "Time Remaining: " .. M.format_time(M.seconds_remaining) .. suffix
    vim.o.winbar = "%=%#Comment#%{%v:lua.require('focus.ui').statusline_component()%}"
    M.handle:start(1000, 1000, function()
        vim.schedule(function()
            if M.seconds_remaining == 0 then
                M.toggle_state()
            else
                M.seconds_remaining = M.seconds_remaining - 1
            end

            local ui = require("focus.ui")
            local suffix = (M.state == "break") and " (Break Time)" or ""
            ui.hud_text = "Time Remaining: " .. M.format_time(M.seconds_remaining) .. suffix

            vim.cmd("redrawstatus")

            ui.update_menu()
        end)
    end)
end

function M.stop()
    if not M.handle then
        vim.notify("Timer not running", vim.log.levels.INFO)
    else
        M.handle:stop()
        M.handle:close()
        M.handle = nil
        M.isPaused = true

        vim.o.winbar = ""
        local ui = require("focus.ui")
        ui.hud_text = ""
        ui.update_menu()
    end
end

function M.format_time(total_seconds)
    local minutes = math.floor(total_seconds / 60)
    local seconds = math.floor(total_seconds % 60)

    return string.format("%02d:%02d", minutes, seconds)
end

function M.toggle_pause()
    if not M.state then
        M.start()
    elseif M.isPaused then
        M.start()
        vim.notify("Timer Resumed!", vim.log.levels.INFO)
    else
        M.stop()
        vim.notify("Timer Paused!", vim.log.levels.INFO)
    end
end

function M.toggle_state()
    if M.state == "work" then
        M.state = "break"
        M.seconds_remaining = M.config.break_duration * 60
        M.total_seconds = M.config.break_duration * 60
        vim.notify("Take a break!", vim.log.levels.INFO)
    else
        M.state = "work"
        M.seconds_remaining = M.config.work_duration * 60
        M.total_seconds = M.config.work_duration * 60
        vim.notify("Back to Work!", vim.log.levels.INFO)
    end
end

return M
