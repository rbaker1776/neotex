local config = require("neotex.config")
local utils = require("neotex.utils")

local M = {}

M.compile = function(on_complete)
    local file = vim.fn.expand("%:p")
    local pdf_file = vim.fn.expand("%:t:r") .. ".pdf"
    
    -- ensure we are working with a LaTeX file
    if not file:match("%.tex$") then
        vim.api.nvim_notify(
            "(neotex) Error: Current file is not a LaTeX file.",
        vim.log.levels.ERROR, {})
        return
    end

    -- validate the LaTeX command
    if not vim.fn.executable(config.latex_cmd) then
        vim.api.nvim_notify(
            "(neotex) Error: LaTeX command '" .. config.latex_cmd .. "' is not executable.",
        vim.log.levels.ERROR, {})
        return
    end

    local cmd = { config.latex_cmd, "-interaction=nonstopmode", "-synctex=1", file }

    vim.fn.jobstart(cmd, {
        stdout_buffered = true,
        stderr_buffered = true,
        on_stdout = function(_, data)
            if data then
                vim.api.notify(
                    "(neotex) STDOUT: " .. table.concat(data, '\n'),
                vim.log.levels.INFO, {})
            end
        end,
        on_stderr = function(_, data)
            if data then
                vim.api.notify(
                    "(neotex) STDERR: " .. table.concat(data, '\n'),
                vim.log.levels.ERROR, {})
            end
        end,
        on_exit = function(_, code)
            if code == 0 then
                vim.api.notify(
                    "(neotex) LaTeX compilation successful.",
                vim.log.levels.INFO, {}) 
                if on_complete then
                    on_complete(true)
                end
            else
                vim.api.notify(
                    "(neotex) Error: LaTeX compilation failed.",
                vim.log.levels.ERROR, {}) 
                if on_complete then
                    on_complete(false)
                end
            end
        end,
    })
end

M.open_pdf = function(on_complete)
    local pdf_file = vim.fn.expand("%:p:r") .. ".pdf"

    -- validate PDF viewer
    if not vim.fn.executable(config.pdf_viewer) then
        vim.api.nvim_notify(
            "(neotex) Error: PDF viewer '" .. "' is not found.",
        vim.log.levels.ERROR, {})
        return
    end

    -- ensure target PDF exists
    if utils.file_exists(pdf_file) then
        vim.api.notify(
            "(neotex) Opening " .. pdf_file .. "...",
        vim.log.levels.INFO, {})
        vim.fn.jobstart({ config.pdf_viewer, pdf_file }, { detach = true })
    else
        vim.api.notify(
            "(neotex) Error: File " .. pdf_file .. " does not exist.",
        vim.log.levels.ERROR, {})
    end
end

M.preview = function()
    M.compile(function(did_compile)
        if not did_compile then
            return
        end
        M.open_pdf()
    end)
end

return M
