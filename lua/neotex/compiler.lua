local config = require("neotex.config")
local logger = require("neotex.logger")
local parser = require("neotex.parser")
local futils = require("neotex.futils")


local Compiler = {}

-- initialize message storage
Compiler._stdout_msgs = {}
Compiler._stderr_msgs = {}

Compiler._did_compile = false
Compiler._did_complete = false


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

    if not futils.assert_file_exists(filename, ".log") then return end

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

Compiler.did_complete = function()
    return (Compiler._did_complete == true)
end

Compiler.compile = function(filename)
    Compiler._did_compile = false
    Compiler._did_complete = false

    -- validate LaTeX file and executable compile command
    if not futils.assert_file_exists(filename .. ".tex") then return end
    if not futils.assert_is_executable("pdflatex") then return end

    for i, v in ipairs(Compiler._stdout_msgs) do Compiler._stdout_msgs[i] = nil end
    for i, v in ipairs(Compiler._stderr_msgs) do Compiler._stderr_msgs[i] = nil end

    local output_pdf = filename .. ".pdf"
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
        end,
    })
end

Compiler.await_compile = function(filename, on_complete)
    local co = coroutine.create(function()
        Compiler.compile(filename)

        while not (compiler.did_complete()) do
            vim.fn.sleep(25)
            coroutine.yield()
        end

        on_complete()
    end)
    coroutine.resume(co)
end


return Compiler
