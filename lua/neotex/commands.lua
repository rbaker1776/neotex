local config = require("neotex.config")

local M = {}

M.compile = function()
    local file = vim.fn.expand("%:p")

    -- ensure we are working with a LaTeX file
    if not file:match("%.tex$") then
        print("(neotex) Error: Current file is not a LaTeX file.")
        return
    end

    -- validate the LaTeX command
    if not vim.fn.executable(config.latex_cmd) then
        print("(neotex) Error: LaTeX command '" .. config.latex_cmd .. "' is not executable.")
        return
    end

    local cmd = { config.latex_cmd, "-interaction=nonstopmode", file }

    vim.fn.jobstart(cmd, {
        stdout_buffered = true,
        on_stdout = function(_, data)
            if data then
                print("(neotex) STDOUT: " .. table.concat(data, '\n'))
            end
        end,
        on_stderr = function(_, data)
            if data then
                print("(neotex) STDERR: " .. table.concat(data, '\n'))
            end
        end,
        on_exit = function(_, code)
            print("done")
            return
            --if code == 0 then
             --   print("(neotex) Compilation successful.")
            --else
              --  print("(neotex) Error: Compilation failed.")
            --end
        end,
    })
end

return M
