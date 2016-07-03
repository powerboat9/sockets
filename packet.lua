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

function sendPacket(str, encryption, n)
    if type(str) ~= "string" then error("Message is a " .. type(str) .. ", expected a string", 2) end
    if (encryption ~= "PLAIN") and (encryption ~= "RSA") and (encryption ~= "AES") then error("Invalid encryption type", 2) end
