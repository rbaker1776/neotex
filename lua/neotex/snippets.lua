local lsnip = require("luasnip")
local lss = lsnip.snippet
local lst = lsnip.text_node
local lsi = lsnip.insert_node

lsnip.add_snippets("tex", {
    -- \begin{enviornment} ... \end{enviornment}
    lss("env", {
        lst("\\begin{"), lsi(1, "enviornment"), lst({'}', '\t'}), lsi(0),
        lst({"", "\\end{"}), lsi(1), lst('}')
    }),
})
