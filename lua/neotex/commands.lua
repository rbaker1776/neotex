local config = require("neotex.config")
local logger = require("neotex.logger")
local parser = require("neotex.parser")
local fileutils = require("neotex.futils")
local utils = require("neotex.utils")

local M = {}


M.is_live_compile = false


M.forward_search = function()
    utils.ensure_dbus() -- ensure D-Bus is running

    local tex_file = vim.fn.expand("%:p")
    local line = vim.fn.line('.')
    local col = vim.fn.col('.')
    local pdf_file = vim.fn.expand("%:p:r") .. ".pdf"

    -- ensure the PDF viewer is executable
    if not vim.fn.executable(config.pdf_viewer) then
        logger.error("PDF viewer is not found.")
        return
    end

    -- ensure PDF exists
    if not fileutils.file_exists(pdf_file) then
        logger.error("PDF file not found.")
        return
    end

    local cmd = {
        config.pdf_viewer,
        "--synctex-forward",
        string.format("%d:%d:%s", line, col, tex_file),
        pdf_file
    }

    vim.fn.jobstart(cmd, { detach = true })
    logger.info(string.format("Forward search executed from line %d.", line))
end

M.jump_to = function(line, file)
    if not file or file == "" or not fileutils.file_exists(file) then
        logger.error("SyncTeX jump file not found.")
        return
    end
    vim.api.nvim_command("edit " .. vim.fn.fnameescape(file))
    vim.fn.cursor(line, 1)
    logger.info("Jumped to line " .. line .. '.')
end

return M
