local commands = require("neotex.commands")

local M = {}

local keymap = vim.keymap

M.setup = function()

    keymap.set('n', '<leader>lc', function()
        commands.compile()
    end, { noremap = true, silent = true, desc = "Compile LaTeX" })

    keymap.set('n', '<leader>lo', function()
        commands.open_pdf()
    end, { noremap = true, silent = true, desc = "Open PDF" })

    keymap.set('n', '<leader>lp', function()
        commands.preview()
    end, { noremap = true, silent = true, desc = "Compile LaTeX and open PDF" })
end

return M
