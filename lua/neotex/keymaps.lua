local M = {}

M.setup = function()
    vim.api.nvim_set_keymap('n', '<leader>lc', ":lua require('neotex.commands').compile()<CR>")
end

return M
