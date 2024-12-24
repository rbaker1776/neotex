local M = {}

function M.black(text, end)
    end = end or '\n'
    io.write("\27[30m" .. text .. "\27[0m" .. end)
end

function M.red(text, end)
    end = end or '\n'
    io.write("\27[31m" .. text .. "\27[0m" .. end)
end

function M.green(text, end)
    end = end or '\n'
    io.write("\27[32m" .. text .. "\27[0m" .. end)
end

function M.yellow(text, end)
    end = end or '\n'
    io.write("\27[33m" .. text .. "\27[0m" .. end)
end

function M.blue(text, end)
    end = end or '\n'
    io.write("\27[34m" .. text .. "\27[0m" .. end)
end

function M.purple(text, end)
    end = end or '\n'
    io.write("\27[35m" .. text .. "\27[0m" .. end)
end

function M.cyan(text, end)
    end = end or '\n'
    io.write("\27[36m" .. text .. "\27[0m" .. end)
end

function M.gray(text, end)
    end = end or '\n'
    io.write("\27[37m" .. text .. "\27[0m" .. end)
end

return M
