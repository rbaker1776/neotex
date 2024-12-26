local config = require("neotex.config")
local utils = require("neotex.utils")
local logger = require("neotex.logger")

local M = {}

M.compile = function(on_complete)
    local tex_file = vim.fn.expand("%:p") -- full path to current file
    local pdf_file = vim.fn.expand("%:t:r") .. ".pdf" -- final PDF
    local tmp_file = vim.fn.expand("%:t:r") .. ".tmp" -- temporary PDF
    
    -- ensure we are working with a LaTeX file
    if not utils.is_latex_file(tex_file) then
        logger.error("Current file is not a LaTeX file.")
        return
    end

    -- validate the LaTeX command
    if not vim.fn.executable(config.latex_cmd) then
        logger.error("LaTeX command '" .. config.latex_cmd .. "' is not executable.")
        return
    end

    local cmd = {
        config.latex_cmd,
        "-interaction=nonstopmode",
        "-synctex=1",
        "-jobname=" .. tmp_file,
        tex_file
    }

    vim.fn.jobstart(cmd, {
        stdout_buffered = true,
        stderr_buffered = true,
        on_stdout = function(_, data)
            --if data and not M.live_compile then
            --    logger.debug("STDOUT: " .. table.concat(data, '\n'))
            --end
        end,
        on_stderr = function(_, data)
            --if data and not M.live_compile then
            --    logger.error("STDERR: " .. table.concat(data, '\n'))
            --end
        end,
        on_exit = function(_, code)
            local out_file = tmp_file .. ".pdf"
            if code == 0 then -- compilation succeeded
                if utils.file_exists(out_file) then -- valid output: success path
                    os.rename(out_file, pdf_file)
                    logger.info("LaTeX compilation successful.")
                    if on_complete then on_complete(true) end
                    return
                else
                    logger.error("Temporary PDF not found.")
                end
            else -- compilation failed
                if utils.file_exists(out_file) then
                    os.remove(out_file)
                end
                logger.error("LaTeX compilation failed.")
            end
            if on_complete then on_complete(false) end
        end,
    })
end

M.open_pdf = function(on_complete)
    local pdf_file = vim.fn.expand("%:p:r") .. ".pdf"

    -- validate PDF viewer
    if not vim.fn.executable(config.pdf_viewer) then
        logger.error("PDF viewer is not found.")
        return
    end

    -- ensure target PDF exists
    if not utils.file_exists(pdf_file) then
        logger.error("File " .. pdf_file .. " does not exist.")
        return
    end

    local editor_command = string.format(
        "nvim --server %s --remote-send '<ESC>:lua require(\"neotex.commands\").jump_to(%%l, \"%%f\")<CR>'",
        vim.v.servername
    )
    local cmd = {
        config.pdf_viewer,
        "--synctex-editor-command",
        editor_cmd,
        pdf_file
    }

    logger.info("Opening " .. pdf_file .. "...")
    vim.fn.jobstart(cmd, { detach = true })
end

M.preview = function()
    M.compile(function(did_compile)
        if not did_compile then
            return
        end
        M.open_pdf()
    end)
end

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
    if not utils.is_latex_file(tex_file) then
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
    if not utils.file_exists(pdf_file) then
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
    if not file or file == "" or not utils.file_exists(file) then
        logger.error("SyncTeX jump file not found.")
        return
    end
    vim.api.nvim_command("edit " .. vim.fn.fnameescape(file))
    vim.fn.cursor(line, 1)
    logger.info("Jumped to line " .. line .. '.')
end

return M
