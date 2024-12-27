local config = require("neotex.config")
local logger = require("neotex.logger")
local futils = require("neotex.futils")


local Viewer = {}

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

return Viewer
