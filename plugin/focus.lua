vim.api.nvim_create_user_command("FocusStart", function()
    require("focus.timer").start()
end, { desc = "Start the Timer" })
vim.api.nvim_create_user_command("FocusStop", function()
    require("focus.timer").stop()
end, { desc = "Stop the Timer" })

vim.api.nvim_create_user_command("FocusMenu", function()
    require("focus.ui").menu()
end, { desc = "Open Focus Menu" })

-- local focusGroup = vim.api.nvim_create_augroup("FocusGroup", { clear = true })
