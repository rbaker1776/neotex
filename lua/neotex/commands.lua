local config = require("neotex.config")
local logger = require("neotex.logger")
local parser = require("neotex.parser")
local fileutils = require("neotex.futils")
local utils = require("neotex.utils")

local M = {}


M.is_live_compile = false

M.enable_live_compile = function()
    -- autocommand group for live compile
    local group_id = vim.api.nvim_create_augroup("neotex_live_compile", { clear = true })

    vim.api.nvim_create_autocmd({ "BufWritePost", "TextChanged" }, {
        group = group_id,
        pattern = "*.tex",
        callback = function()
            -- debounce logic to prevent overlapping compilations
            if M.debounce_timer then
                M.debounce_timer:stop()
                M.debounce_timer:close()
            end

            M.debounce_timer = vim.loop.new_timer()
            M.debounce_timer:start(500, 0, vim.schedule_wrap(function()
                M.compile(function(did_compile)
                    -- maybe implement logic here
                end)
            end))
        end,
    })

    M.is_live_compile = true
    logger.info("Live compilation enabled.")
end

M.disable_live_compile = function()
    vim.api.nvim_del_augroup_by_name("neotex_live_compile")
    if M.debounce_timer then
        M.debounce_timer:stop()
        M.debounce_timer:close()
        M.debounce_timer = nil
    end

    M.is_live_compile = false
    logger.info("Live compilation disabled.")
end

M.toggle_live_compile = function()
    if not fileutils.is_tex_file(tex_file) then
        logger.error("Current file is not a LaTeX file.")
        return
    end
    if not M.is_live_compile then
        M.enable_live_compile()
    else
        M.disable_live_compile()
    end
end

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
