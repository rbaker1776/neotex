local config = require("neotex.config")
local logger = require("neotex.logger")
local parser = require("neotex.parser")
local futils = require("neotex.futils")


local Compiler = {}

-- initialize message storage
Compiler._stdout_msgs = {}
Compiler._stderr_msgs = {}

Compiler._did_compile = false


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

    local _, warnings, overfulls = parser.parse_log(filename .. ".log")

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

    -- move the temp PDF file into the filal PDF file
    os.rename(tmp_pdf, pdf_file)
    logger.info("LaTeX compilation successful.")
    Compiler._did_compile = true
end

local function handle_failure(filename)
    logger.error("LaTeX compilation failed.")

    if not futils.assert_file_exists(filename .. ".tmp.pdf") then return end

    os.remove(filename .. ".tmp.pdf")

    local errors, _, _ = parser.parse_log(filename .. ".log")

    if #errors > 0 then
        logger.error("Errors during compilation:")
        for _, msg in ipairs(errors) do
            logger.error(msg)
        end
    end
end


Compiler.did_compile = function()
    return (Compiler._did_compile == true)
end

Compiler.compile = function(filename)
    Compiler._did_compile = false

    -- validate LaTeX file and executable compile command
    if not futils.assert_file_exists(filename .. ".tex") then return end
    if not futils.assert_is_executable("pdflatex") then return end

    print("removing")
    for i, v in ipairs(Compiler._stdout_msgs) do Compiler._stdout_msgs[i] = nil end
    for i, v in ipairs(Compiler._stderr_msgs) do Compiler._stderr_msgs[i] = nil end

    local output_pdf = filename .. ".pdf"
    local output_tmp = filename .. ".tmp"

    local cmd = {
        "pdflatex",
        "-interaction=nonstopmode",
        "-synctex=1",
        "-jobname-" .. output_tmp,
        filename .. "tex",
    }

    vim.fn.jobstart(cmd, {
        stdout_buffered = true,
        stderr_buffered = true,
        on_stdout = handle_stdout,
        on_stderr = handle_stderr,
        on_exit = function(_, code)
            print(filename .. ".tex")
            if code == 0 then
                handle_success(filename)
            else
                handle_failure(filename)
            end
        end,
    })
end


return Compiler
