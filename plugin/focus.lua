vim.api.nvim_create_user_command("FocusStart", function()
    require("focus.timer").start()
end, { desc = "Start the Timer" })
vim.api.nvim_create_user_command("FocusStop", function()
    require("focus.timer").stop()
end, { desc = "Stop the Timer" })

vim.api.nvim_create_user_command("FocusMenu", function()
    require("focus.ui").menu()
end, { desc = "Open Focus Menu" })

vim.keymap.set("n", "<leader>fs", function()
    require("focus.timer").start()
end, { desc = "Start the Timer" })
vim.keymap.set("n", "<leader>fq", function()
    require("focus.timer").stop()
end, { desc = "Stop the Timer" })

local focusGroup = vim.api.nvim_create_augroup("FocusGroup", { clear = true })

vim.api.nvim_create_autocmd("FocusGained", {
    group = focusGroup,
    pattern = "*",
    callback = function()
        require("focus.timer").start()
    end
})
vim.api.nvim_create_autocmd("FocusLost", {
    group = focusGroup,
    pattern = "*",
    callback = function()
        require("focus.timer").stop()
    end
})
