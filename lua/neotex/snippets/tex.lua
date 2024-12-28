local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

return {
    s("env", {
        t("\\begin{"), i(1, "environment"), t("}"), t({"", '\t'}), i(0),
        t({"", "\\end{"}), f(function(args) return args[1][1] end, {1}),
        t("}"),
    }),
}
