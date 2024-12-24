local M = {}

function M.black(text, eol)
    eol = eol or '\n'
    vim.api.nvim_out_write("\x1b[30m" .. text .. "\x1b[0m" .. eol)
end

function M.red(text, eol)
    eol = eol or '\n'
    vim.api.nvim_out_write("\x1b[31m" .. text .. "\x1b[0m" .. eol)
end

function M.green(text, eol)
    eol = eol or '\n'
    vim.api.nvim_out_write("\x1b[32m" .. text .. "\x1b[0m" .. eol)
end

function M.yellow(text, eol)
    eol = eol or '\n'
    vim.api.nvim_out_write("\x1b[33m" .. text .. "\x1b[0m" .. eol)
end

function M.blue(text, eol)
    eol = eol or '\n'
    vim.api.nvim_out_write("\x1b[34m" .. text .. "\x1b[0m" .. eol)
end

function M.purple(text, eol)
    eol = eol or '\n'
    vim.api.nvim_out_write("\x1b[35m" .. text .. "\x1b[0m" .. eol)
end

function M.cyan(text, eol)
    eol = eol or '\n'
    vim.api.nvim_out_write("\x1b[36m" .. text .. "\x1b[0m" .. eol)
end

function M.gray(text, eol)
    eol = eol or '\n'
    vim.api.nvim_out_write("\x1b[37m" .. text .. "\x1b[0m" .. eol)
end

return M
