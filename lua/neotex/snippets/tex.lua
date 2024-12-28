local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
    s("env", {
        t("\\begin{"), i(1, "environment"), t("}"),
        t({"", '\t'}), i(0),
        t({"", "\\end{"}), i(2, "environment"), t("}"),
    }),
}
