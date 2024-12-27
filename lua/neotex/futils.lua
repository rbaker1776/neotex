local logger = require("neotex.logger")


local FUitls = {}

FUitls.file_exists = function(filepath)
    local stat = vim.loop.fs_stat(filepath)
    return stat and stat.type == "file"
end

FUitls.assert_file_exists = function(filepath)
    if not FUitls.file_exists(filepath) then
        logger.error("File does not exist: " .. filepath)
        return false
    end
    return true
end

FUitls.is_tex_file = function(filepath)
    return filepath:match("%.tex$")
end

FUitls.assert_is_tex_file = function(filepath)
    if not FUitls.is_tex_file(filepath) then
        logger.error("File is not a LaTeX file: " .. filepath)
        return false
    end
    return true
end

FUitls.is_executable = function(filepath)
    return vim.fn.executable(filepath)
end

FUitls.assert_is_executable = function(filepath)
    if not FUitls.is_executable(filepath) then
        logger.error("File is not executable: " .. filepath)
        return false
    end
    return true
end

FUitls.ensure_dbus = function()
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


return FUitls
