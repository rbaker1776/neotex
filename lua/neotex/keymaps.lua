local commands = require("neotex.commands")
local compiler = require("neotex.compiler")
local pdfviewer = require("neotex.pdfviewer")


local Mapping = {}

local keymap = vim.keymap

Mapping.setup = function()

    keymap.set('n', '<leader>lc', function()
        compiler.compile(vim.fn.expand("%:t:r"))
    end, { noremap = true, silent = true, desc = "Compile LaTeX" })

    keymap.set('n', '<leader>lo', function()
        pdfviewer.open_pdf(vim.fn.expand("%:t:r"))
    end, { noremap = true, silent = true, desc = "Open PDF" })

    keymap.set('n', '<leader>lp', function()
        compiler.compile(vim.fn.expand("%:t:r"))
        if not compiler.did_compile() then return end
        pdfviewer.open_pdf(vim.fn.expand("%:t:r")) -- only open the PDF if compilation succeeded
    end, { noremap = true, silent = true, desc = "Compile LaTeX and open PDF" })

    keymap.set('n', '<leader>ll', function()
        commands.toggle_live_compile()
    end, { noremap = true, silent = true, desc = "Toggle LaTeX live compilaion" })

    keymap.set('n', '<leader>lf', function()
        commands.forward_search()
    end, { noremap = true, silent = true, desc = "Jump to corresponding point in PDF" })
end

return Mapping
