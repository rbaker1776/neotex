local config = require("neotex.config")


Logger = {}
Logger.__index = Logger

Logger.levels =
{
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4,
}

Logger.log = function(level, message)
    if level < config.log_level then
        return
    end

    local styles = { vim.log.levels.INFO, vim.log.levels.INFO, vim.log.levels.WARN, vim.log.levels.ERROR }
    local prefixes = { "Debug: ", "", "Warning: ", "Error: " }

    vim.api.nvim_notify(
        "(neotex) " .. prefixes[level] .. message,
    styles[level], {})
end

Logger.error = function(message)
    Logger.log(Logger.levels.ERROR, message)
end

Logger.warn = function(message)
    Logger.log(Logger.levels.WARN, message)
end

Logger.info = function(message)
    Logger.log(Logger.levels.INFO, message)
end

Logger.debug = function(message)
    Logger.log(Logger.levels.DEBUG, message)
end


return Logger
