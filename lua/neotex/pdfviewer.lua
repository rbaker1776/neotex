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

local function pdf_window_to_front(filename)
    local handle = io.popen("pgrep -f \"zathura(.*)" .. filename .. ".pdf\"")
    local result = handle:read("*a")
    handle:close()
    local cmd = "bring-window-to-front " .. result
    os.execute(cmd)
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
    pdf_window_to_front(filename)
end


return Viewer
