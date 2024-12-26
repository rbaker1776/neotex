local config = require("neotex.config")
local logger = require("neotex.logger")
local utils = require("neotex.utils")

local M = {}

M.parse_log = function(log_file)
    local errors = {}
    local warnings = {}
    local overfulls = {}

    if not utils.file_exists(log_file) then
        logger.error("Log file not found: " .. log_file)
        return errors, warnings, overfulls
    end

    for line in io.lines(log_file) do
        -- match errors
        if line:match("^!") then
            table.insert(errors, line)
        end

        -- match warnings
        if line:match("Warning:") then
            table.insert(warnings, line)
        end

        -- match overfull boxes
        if line:match("Overfull %\\hbox") then
            table.insert(overfulls, line)
        end
    end

    return errors, warnings, overfulls
end

return M
