local M = {}

M.file_exists = function(filepath)
    local stat = vim.loop.fs_stat(filepath)
    return stat and stat.type == "file"
end

M.is_latex_file = function()
    local file = vim.fn.expand("%:p")
    return file:match("%.tex$")
end

return M
