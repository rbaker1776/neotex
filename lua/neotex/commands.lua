local config = require("neotex.config")
local utils = require("neotex.utils")

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

    local success = false

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
                print("(neotex) Compilation successful.")
                success = true
            else
                print("(neotex) Error: Compilation failed.")
            end
        end,
    })

    return success
end

M.open_pdf = function()
    local pdf_file = vim.fn.expand("%:p:r") .. ".pdf"

    -- validate PDF viewer
    if not vim.fn.executable(config.pdf_viewer) then
        print("(neotex) Error: PDF viewer '" .. "' is not found.")
        return
    end

    -- ensure target PDF exists
    if utils.file_exists(pdf_file) then
        print("(neotex) Opening " .. pdf_file .. '.')
        vim.fn.jobstart({ config.pdf_viewer, pdf_file }, { detach = true })
    else
        print("(neotex) Error: File " .. pdf_file .. " does not exist.")
    end
end

M.preview = function()
    if not M.compile() then
        return
    end
    vim.defer_fn(function()
        M.open_pdf()
    end, 500) -- 500ms delay to ensure PDF is written
end

return M
