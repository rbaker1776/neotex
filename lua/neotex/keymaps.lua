local M = {}

M.setup = function()
    vim.keymap.set(
    'n',
    '<leader>lc',
    ":lua require('neotex.commands').compile()<CR>",
    { noremap = true, silent = true })
end

return M
