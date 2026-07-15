local M = {}

function M.setup(opts)
    M.config = opts
    M.seconds_remaining = nil
    M.state = nil
    M.isPaused = nil
    M.handle = nil
end

function M.start()
    if not M.config then return end
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
        M.handle = vim.uv.new_timer()
    end
    M.isPaused = false
    M.handle:start(1000, 1000, function()
        vim.schedule(function()
            if M.state == "break" then
                require("focus.ui").update_hud("Time Remaining: " ..
                    M.format_time(M.seconds_remaining) .. " (Break Time)")
            else
                require("focus.ui").update_hud("Time Remaining: " .. M.format_time(M.seconds_remaining))
            end
            if M.seconds_remaining == 0 then
                M.toggle_state()
            else
                M.seconds_remaining = M.seconds_remaining - 1
            end
            require("focus.ui").update_menu()
        end)
    end)
end

function M.stop()
    if M.handle then
        M.handle:stop()
        M.handle:close()
        M.handle = nil
        M.isPaused = true
        require("focus.ui").update_menu()
        if M.seconds_remaining == 0 then
            require("focus.ui").update_hud("Time's up!")
        else
            require("focus.ui").update_hud("Time: " .. M.format_time(M.seconds_remaining) .. " (Paused)")
        end
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
