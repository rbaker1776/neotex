local logger = require("neotex.logger")

local M = {}

M.file_exists = function(filepath)
    local stat = vim.loop.fs_stat(filepath)
    return stat and stat.type == "file"
end

M.assert_file_exists = function(filepath)
    if not M.file_exists(filepath) then
        logger.error("File does not exist: " .. filepath)
        return false
    end
    return true
end

M.is_tex_file = function(filepath)
    return filepath:match("%.tex$")
end

M.assert_is_tex_file = function(filepath)
    if not M.is_tex_file(filepath) then
        logger.error("File is not a LaTeX file: " .. filepath)
        return false
    end
    return true
end

M.is_executable = function(filepath)
    return vim.fn.executable(filepath)
end

M.assert_is_executable = function(filepath)
    if not M.is_executable(filepath) then
        logger.error("File is not executable: " .. filepath)
        return false
    end
    return true
end

return M
