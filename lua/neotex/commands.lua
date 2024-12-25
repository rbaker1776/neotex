local config = require("neotex.config")
local utils = require("neotex.utils")
local logger = require("neotex.logger")

local M = {}

M.compile = function(on_complete)
    local file = vim.fn.expand("%:p")
    local pdf_file = vim.fn.expand("%:t:r") .. ".pdf"
    
    -- ensure we are working with a LaTeX file
    if not file:match("%.tex$") then
        logger.error("Current file is not a LaTeX file.")
        return
    end

    -- validate the LaTeX command
    if not vim.fn.executable(config.latex_cmd) then
        logger.error("LaTeX command '" .. config.latex_cmd .. "' is not executable.")
        return
    end

    local cmd = { config.latex_cmd, "-interaction=nonstopmode", "-synctex=1", file }

    vim.fn.jobstart(cmd, {
        stdout_buffered = true,
        stderr_buffered = true,
        on_stdout = function(_, data)
            if data then
                logger.debug("STDOUT: " .. table.concat(data, '\n'))
            end
        end,
        on_stderr = function(_, data)
            if data then
                logger.error("STDERR: " .. table.concat(data, '\n'))
            end
        end,
        on_exit = function(_, code)
            local success = (code == 0)
            if success then
                logger.info("LaTeX compilation successful.")
            else
                logger.error("LaTeX compilation failed.")
            end
            if on_complete then
                on_complete(success)
            end
        end,
    })
end

M.open_pdf = function(on_complete)
    local pdf_file = vim.fn.expand("%:p:r") .. ".pdf"

    -- validate PDF viewer
    if not vim.fn.executable(config.pdf_viewer) then
        logger.error("PDF viewer '" .. "' is not found.")
        return
    end

    -- ensure target PDF exists
    if utils.file_exists(pdf_file) then
        logger.info("Opening " .. pdf_file .. "...")
        vim.fn.jobstart({ config.pdf_viewer, pdf_file }, { detach = true })
    else
        logger.error("File " .. pdf_file .. " does not exist.")
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
