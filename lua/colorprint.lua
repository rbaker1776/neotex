local M = {}

function M.black(text, eol)
    eol = eol or '\n'
    vim.api.nvim_out_write("\27[30m" .. text .. "\27[0m" .. eol)
end

function M.red(text, eol)
    eol = eol or '\n'
    vim.api.nvim_out_write("\27[31m" .. text .. "\27[0m" .. eol)
end

function M.green(text, eol)
    eol = eol or '\n'
    vim.api.nvim_out_write("\27[32m" .. text .. "\27[0m" .. eol)
end

function M.yellow(text, eol)
    eol = eol or '\n'
    vim.api.nvim_out_write("\27[33m" .. text .. "\27[0m" .. eol)
end

function M.blue(text, eol)
    eol = eol or '\n'
    vim.api.nvim_out_write("\27[34m" .. text .. "\27[0m" .. eol)
end

function M.purple(text, eol)
    eol = eol or '\n'
    vim.api.nvim_out_write("\27[35m" .. text .. "\27[0m" .. eol)
end

function M.cyan(text, eol)
    eol = eol or '\n'
    vim.api.nvim_out_write("\27[36m" .. text .. "\27[0m" .. eol)
end

function M.gray(text, eol)
    eol = eol or '\n'
    vim.api.nvim_out_write("\27[37m" .. text .. "\27[0m" .. eol)
end

return M
