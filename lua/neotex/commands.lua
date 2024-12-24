local config = require("neotex.config")

local M = {}

M.compile = function()
    local file = vim.fn.expand("%:p")
    print("File: " .. file)
    vim.fn.mkdir(config.build_dir, 'p')

    local cmd = string.format("%s -output-directory=%s %s", config.latex_cmd, config.build_dir, file)
    vim.fn.jobstart(cmd, {
        stdout_buffered = true,
        on_exit = function(_, code)
            if code == 0 then
                print("Compilation successful.")
            else
                print("Compilation failed.")
            end
        end,
    })
end

return M
