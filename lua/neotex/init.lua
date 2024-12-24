local config = require("neotex.config")
local keymaps = require("neotex.keymaps")

local function setup(usr_config)
    config = vim.tbl_deep_extend("force", config, usr_config or {})
    keymaps.setup()
end

return
{
    setup = setup,
}
