function package(str, size)
    if type(str) ~=
    local ret = {}
    while true do
        if #str > size then
            ret[#ret + 1] = str:sub(1, size)
            str = str:sub(size + 1)
        else
            ret[#ret + 1] = str
            break
        end
    end
    return ret
end
