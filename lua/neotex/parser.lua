local config = require("neotex.config")
local logger = require("neotex.logger")
local futils = require("neotex.futils")


local Parser = {}

local function is_error(line)
    return line:match("^!")
end

local function is_warning(file)
    return line:match("Warning:")
end

local function is_overfull(file)
    return line:match("Overfull %\\hbox")
end

Parser.parse_log = function(filename)
    --[[
    local errors = {}
    local warnings = {}
    local overfulls = {}

    if not futils.assert_file_exists(filename .. ".log") then
        return errors, warnings, overfulls
    end

    for line in io.lines(log_file) do
        if is_error(line) then table.insert(errors, line) end
        if is_warning(line) then table.insert(warnings, line) end
        if is_overfull(line) then table.insert(overfulls, line) end
    end

    return errors, warnings, overfulls
    --]]
end

return Parser
