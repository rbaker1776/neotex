local M = {}

function M.black(text)
    print("\27[30m" .. text .. "\27[0m")
end

function M.red(text)
    print("\27[31m" .. text .. "\27[0m")
end

function M.green(text)
    print("\27[32m" .. text .. "\27[0m")
end

function M.yellow(text)
    print("\27[33m" .. text .. "\27[0m")
end

function M.blue(text)
    print("\27[34m" .. text .. "\27[0m")
end

function M.purple(text)
    print("\27[35m" .. text .. "\27[0m")
end

function M.cyan(text)
    print("\27[36m" .. text .. "\27[0m")
end

function M.gray(text)
    print("\27[37m" .. text .. "\27[0m")
end

return M
