local config = require("neotex.config")
local logger = require("neotex.logger")
local parser = require("neotex.parser")
local futils = require("neotex.futils")


local Compiler = {}

-- initialize message storage
Compiler._stdout_msgs = {}
Compiler._stderr_msgs = {}

Compiler._did_compile = false

Compiler._is_live = false
Compiler._debounce_timer = nil


local function handle_stdout(data)
    if data and data ~= "" then
        local msg = table.concat(data, '\n')
        --logger.debug("STDOUT: " .. message)
        table.insert(Compiler._stdout_msgs, msg)
    end
end

local function handle_stderr(data)
    if data and data ~= "" then
        local msg = table.concat(data, '\n')
        --logger.error("STDERR: " .. message)
        table.insert(_stderr_msgs, msg)
    end
end


local function handle_success(filename)
    if not futils.assert_file_exists(filename .. ".tmp.pdf") then return end

    --[[
    local _, warnings, overfulls = parser.parse_log(filename .. ".tmp.log")

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
    --]]

    -- move the temp PDF file into the filal PDF file
    os.rename(filename .. ".tmp.pdf", filename .. ".pdf")
    Compiler._did_compile = true
    Compiler._did_complete = true
    logger.info("LaTeX compilation successful.")
end

local function handle_failure(filename)
    logger.error("LaTeX compilation failed.")

    if futils.file_exists(filename .. ".tmp.pdf") then 
        os.remove(filename .. ".tmp.pdf")
    end

    if not futils.assert_file_exists(filename .. ".tmp.log") then return end

    local errors, _, _ = parser.parse_log(filename .. ".tmp.log")

    if #errors > 0 then
        logger.error("Errors during compilation:")
        for _, msg in ipairs(errors) do
            logger.error(msg)
        end
    end

    Compiler._did_complete = true
end


Compiler.did_compile = function()
    return (Compiler._did_compile == true)
end

Compiler.is_live = function()
    return (Compiler._is_live == true)
end


Compiler.compile = function(filename, on_complete)
    Compiler._did_compile = false
    Compiler._did_complete = false

    -- validate LaTeX file and executable compile command
    if not futils.assert_file_exists(filename .. ".tex") then return end
    if not futils.assert_is_executable("pdflatex") then return end

    for i, v in ipairs(Compiler._stdout_msgs) do Compiler._stdout_msgs[i] = nil end
    for i, v in ipairs(Compiler._stderr_msgs) do Compiler._stderr_msgs[i] = nil end

    local output_tmp = filename .. ".tmp"

    local cmd = {
        "pdflatex",
        "-interaction=nonstopmode",
        "-synctex=1",
        "-jobname=" .. output_tmp,
        filename .. ".tex",
    }

    vim.fn.jobstart(cmd, {
        stdout_buffered = true,
        stderr_buffered = true,
        on_stdout = handle_stdout,
        on_stderr = handle_stderr,
        on_exit = function(_, code)
            if code == 0 then
                handle_success(filename)
            else
                handle_failure(filename)
            end
            if on_complete then on_complete() end
        end,
    })
end


Compiler.enliven = function(filename)
    -- autocommand group for live compile
    local group_id = vim.api.nvim_create_augroup("neotex_enliven", { clear = true })

    vim.api.nvim_create_autocmd({ "BufWritePost", "TextChanged" }, {
        group = group_id,
        pattern = "*.tex",
        callback = function()
            -- debounce logic to prevent overlapping compilations
            if Compiler._debounce_timer then
                Compiler._debounce_timer:stop()
                Compiler._debounce_timer:close()
            end
            Compiler._debounce_timer = vim.loop.new_timer()
            Compiler._debounce_timer:start(500, 0, vim.schedule_wrap(function()
                Compiler.compile(filename, function()
                    -- maybe implement logic here
                end)
            end))
        end,
    })

    Compiler._is_live = true
    logger.info("Live compilation enabled.")
end

Compiler.unalive = function()
    vim.api.nvim_del_augroup_by_name("neotex_enliven")
    if Compiler._debounce_timer then
        Compiler._debounce_timer:stop()
        Compiler._debounce_timer:close()
        Compiler._debounce_timer = nil
    end

    Compiler._is_live = false
    logger.info("Live compilation disabled.")
end

Compiler.toggle_liveliness = function(filename)
    if not futils.assert_is_tex_file(filename .. ".tex") then return end
    if not Compiler._is_live then
        Compiler.enliven(filename)
    else
        Compiler.unalive()
    end
end


return Compiler
