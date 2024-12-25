local config = require("neotex.config")

local M = {}

M.compile = function()
    local file = vim.fn.expand("%:p")
    local pdf_file = vim.fn.expand("%:t:r") .. ".pdf"
    
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

    local cmd = { config.latex_cmd, "-interaction=nonstopmode", "-synctex=1", file }

    vim.fn.jobstart(cmd, {
        stdout_buffered = true,
        stderr_buffered = true,
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
            if code == 0 then
                print("(neotex) Compilation successful. Opening PDF...")
                M.open_pdf(pdf_file)
            else
                print("(neotex) Error: Compilation failed.")
            end
        end,
    })
end

M.open_pdf = function(pdf_file)
    vim.fn.jobstart({ "zathura", pdf_file }, {
        on_exit = function(_, code)
            if code ~= 0 then
                print("(neotex) Error: Failed to open PDF with Zathura.")
            end
        end,
    })
end

return M
