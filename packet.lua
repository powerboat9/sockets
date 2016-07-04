local version = "0.1.0-developement"

local function package(str, size)
    if type(str) ~= "string" then error("Input is a " .. type(str) .. ", expected a string", 2) end
    if type(size) ~= "number" then error("Size is a " .. type(size) .. ", expected a number", 2) end
    if size < 1 then error("Size cannot be less than 1", 2) end
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

function getRawPacket(str, encryption, to, from, n, key)
    if type(str) ~= "string" then error("Message is a " .. type(str) .. ", expected a string", 2) end
    local eMsg
    if encryption == "RSA" then
        and (encryption ~= "AES") then error("Invalid encryption type", 2) end
    local packetRet = {
        _pgram = " powerboat9:sockets",
        _version = version,
        to = to,
        from = from,
        
