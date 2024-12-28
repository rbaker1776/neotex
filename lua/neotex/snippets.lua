local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

ls.add_snippets("tex", {
    s("env", {
        t("\\begin{"), 
        i(1, "environment"), -- First input for the environment name
        t("}"),
        t({"", '\t'}), 
        i(0), -- Placeholder for content inside the environment
        t({"", "\\end{"}), 
        f(function(args) return args[1][1] end, {1}), -- Dynamically mirrors the first input node
        t("}"),
    })
})
