local config = require("neotex.config")
local logger = require("neotex.logger")
local parser = require("neotex.parser")
local fileman = require("neotex.fileutils")

local M = {}

-- M.compile() compiles the current LaTeX file and outputs <filename>.pdf
-- on_complete() is a callback responsible for informing the caller if compilation succeeded
-- M.compile() is responsible for calling the .log file parser in the event of an error
M.compile = function(on_complete)
    local tex_file = vim.fn.expand("%:p")
    local pdf_file = vim.fn.expand("%:t:r") .. ".pdf" -- final PDF
    local tmp_file = vim.fn.expand("%:t:r") .. ".tmp" -- temporary PDF
    local log_file = vim.fn.expand("%:t:r") .. ".tmp.log"
    
    -- validate LaTeX file and executable compile command
    if not fileman.assert_is_tex_file(tex_file) then return end
    if not fileman.assert_is_executable(config.latex_cmd) then return end

    -- initialize message storage
    local stdout_msgs = {}
    local stderr_msgs = {}

    local handle_stdout = function(data)
        if data and data ~= "" then
            local msg = table.concat(data, '\n')
            --logger.debug("STDOUT: " .. message)
            table.insert(stdout_msgs, msg)
        end
    end

    local handle_stderr = function(data)
        if data and data ~= "" then
            local msg = table.concat(data, '\n')
            --logger.error("STDERR: " .. message)
            table.insert(stderr_msgs, msg)
        end
    end

    local handle_exit = function(code)
        local tmp_pdf = tmp_file .. ".pdf"
        if code == 0 then
            handle_success(tmp_file, pdf_file, log_file, stdout_msgs, stderr_msgs, on_complete)
        else
            handle_failure(tmp_file, pdf_file, log_file, stdout_msgs, stderr_msgs, on_complete)
        end
    end

    local cmd = {
        config.latex_cmd,
        "-interaction=nonstopmode",
        "-synctex=1",
        "-jobname=" .. tmp_file,
        tex_file,
    }

    vim.fn.jobstart(cmd, {
        stdout_buffered = true,
        stderr_buffered = true,
        on_stdout = handle_stdout,
        on_stderr = handle_stderr,
        on_exit = handle_exit,
    })
end

-- handle_success() is called after a successful compilation
local function handle_success(tmp_file, pdf_file, log_file, stdout_msgs, stderr_msgs, on_complete)
    if not fileman.assert_file_exists(tmp_file) then
        if on_complete then on_complete(false) end
        return
    end

    -- no errors because compilation was a success
    local _, warnings, overfulls = parser.parse_log(log_file)

    if #warnings > 0 then
        logger.warn("Warnings found:")
        for _, warning in ipairs(warnings) do
            logger.warn(warning)
        end
    end

    if #overfulls > 0 then
        logger.warn("Overfull boxed found:")
        for _, hbox in ipairs(overfulls) do
            logger.warn(hbox)
        end
    end

    -- move the temp PDF file to the final PDF file
    os.rename(tmp_file, pdf_file)
    logger.info("LaTeX compilation successful.")
    if on_complete then on_complete(true) end
end

-- handle_failure() is called after a failed compilation
local function handle_failure()
    if not fileman.assert_file_exists(tmp_file) then
        if on_complete then on_complete(false) end
        return
    end

    logger.error("LaTeX compilation failed.")

    if #stderr_msgs > 0 then
        logger.error("Errors during compilation:")
        for _, msg in ipairs(stderr_msgs) do
            logger.error(msg)
        end
    end

    if on_complete then on_complete(true) end
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
