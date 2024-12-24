local config = require("neotex.config")

local M = {}

M.compile = function()
    local file = vim.fn.expand("%:p")
    vim.fn.mkdir(config.build_dir, 'p')

    local cmd = { config.latex_cmd, "-output-directory=" .. config.build_dir, file }

    vim.fn.jobstart(cmd, {
        stdout_buffered = false,
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
