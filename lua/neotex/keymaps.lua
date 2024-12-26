local commands = require("neotex.commands")
local compiler = require("neotex.compiler")

local M = {}

local keymap = vim.keymap

M.setup = function()

    keymap.set('n', '<leader>lc', function()
        compiler.compile(vim.fn.expand("%:t:r"))
    end, { noremap = true, silent = true, desc = "Compile LaTeX" })

    keymap.set('n', '<leader>lo', function()
        commands.open_pdf()
    end, { noremap = true, silent = true, desc = "Open PDF" })

    keymap.set('n', '<leader>lp', function()
        commands.preview()
    end, { noremap = true, silent = true, desc = "Compile LaTeX and open PDF" })

    keymap.set('n', '<leader>ll', function()
        commands.toggle_live_compile()
    end, { noremap = true, silent = true, desc = "Toggle LaTeX live compilaion" })

    keymap.set('n', '<leader>lf', function()
        commands.forward_search()
    end, { noremap = true, silent = true, desc = "Jump to corresponding point in PDF" })
end

return M
