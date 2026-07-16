local M = {}

local defaults = {
    work_duration = 25,
    break_duration = 5,
}

function M.setup(opts)
    M.config = vim.tbl_deep_extend("force", defaults, opts or {})
    require("focus.timer").setup(M.config)
end

function M.focus()
    require("focus.timer").start()
end

return M
