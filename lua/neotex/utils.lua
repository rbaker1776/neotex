local logger = require("neotex.logger")

local M = {}

M.file_exists = function(filepath)
    local stat = vim.loop.fs_stat(filepath)
    return stat and stat.type == "file"
end

M.is_latex_file = function()
    local file = vim.fn.expand("%:p")
    return file:match("%.tex$")
end

M.ensure_dbus = function()
    if not os.getenv("DBUS_SESSION_BUS_ADDRESS") then
        local handle = io.popen("dbus-daemon --session --fork --print-address")
        if handle then
            local address = handle:read("*a"):match("%S+")
            handle:close()
            if address then
                vim.env.DBUS_SESSION_BUS_ADDRESS = address
            else
                logger.error("Failed to start D-Bus daemon.")
            end
        else
            logger.error("Could not start D-Bus daemon.")
        end
    end
end

return M
