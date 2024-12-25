local config = require("neotex.config")

M = {}
M.__index = M

M.levels =
{
    DEBUG = 0,
    INFO = 1,
    WARN = 2,
    ERROR = 3,
}

M.log = function(level, message)
    if level < config.log_level then
        return
    end

    local styles = { vim.log.levels.INFO, vim.log.levels.INFO, vim.log.levels.WARN, vim.log.levels.ERROR }
    local prefixes = { "Debug: ", "", "Warning: ", "Error: " }

    vim.api.nvim_notify(
        "(neotex) " .. prefixes[level] .. message,
    styles[level], {})
end

M.error = function(message)
    M.log(M.levels.ERROR, message)
end

M.warn = function(message)
    M.log(M.levels.WARN, message)
end

M.info = function(message)
    M.log(M.levels.INFO, message)
end

M.debug = function(message)
    M.log(M.levels.DEBUG, message)
end

return M
