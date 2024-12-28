local config = require("neotex.config")
local keymaps = require("neotex.keymaps")

local function setup(usr_config)
    config = vim.tbl_deep_extend("force", config, usr_config or {})
    keymaps.setup()

    local luasnip = require("luasnip")

    luasnip.config.set_config({
        history = true,
        updateevents = "TextChanged,TextChangedI",
        enable_autosnippets = true,
    })
end

return {
    setup = setup,
}
