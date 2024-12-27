local config = require("neotex.config")
local logger = require("neotex.logger")
local futils = require("neotex.futils")


local Viewer = {}


local function pdf_is_open(filename)
    local handle = io.popen("pgrep -f \"zathura(.*)" .. filename .. ".pdf\"")
    local result = handle:read("*a")
handle:close()
    return (result ~= "")
end


Viewer.open_pdf = function(filename)
    -- verify PDF and PDF viewer
    if not futils.assert_file_exists(filename .. ".pdf") then return end
    if not futils.assert_is_executable("zathura") then return end

    local cmd = {
        "zathura",
        "--synctex-editor-command",
        string.format(
            "nvim --server %s --remote-send '<ESC>:lua require(\"neotex.commands\").jump_to(%%l, \"%%f\")<CR>'",
            vim.v.servername
        ),
        filename .. ".pdf",
    }

    logger.info("Opening " .. filename .. ".pdf")
    vim.fn.jobstart(cmd, { detach = true })
end

Viewer.view_pdf = function(filename)
    -- verify PDF and PDF viewer
    if not futils.assert_file_exists(filename .. ".pdf") then return end
    if not futils.assert_is_executable("zathura") then return end

    if not pdf_is_open(filename) then Viewer.open_pdf(filename) end
    -- pdf_window_to_front(filename)
end


Viewer.pdf_jump = function(filename)
    if not fuitls.assert_file_exists(filename .. ".pdf") then return end
    if not fuitls.assert_is_executable("zathura") then return end
    futils.ensure_dbus()

    local line = vim.fn.line('.')
    local col = vim.fn.col('.')

    local cmd = {
        "zathura",
        "--synctex-forward",
        string.format("%d:%d:%s", line, col, filename .. ".tex"),
        filename .. ".pdf",
    }

    vim.fn.jobstart(cmd, { detach = true })
    logger.info(string.format("Jump executed from line %d.", line))
end


return Viewer
