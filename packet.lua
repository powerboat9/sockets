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

local function bind(packets)
    if type(packets) ~= "table" then error("Invalid packet list, got type " .. type(packets), 2) end
    if #packets < 1 then error("Cannot combine zero packets", 2) end
    for k, v in ipairs(packets) do
        if type(v) ~= "table" then error("Invalid packet, got type " .. type(v), 2) end
        v.size = #packets
        v.n = k
    end
    return packets
end

local function getRawPacket(str, to, from)
    if not PCrypt.convert.isH(str, 128) then
        error("Message is not a 128 byte hexadecimal string", 2)
    end
    return {
        _pgram = " powerboat9:sockets",
        _version = version,
        to = to,
        from = from,
        msg = str,
        msgID = PCrypt.convert.randH(32)
    }
end

local function getRSAPackets(str, to, from, recevPubKey, sendPrivKey)
    if type(str) ~= "string" then
        error("Message is not a 128 byte hexadecimal string", 2)
    end
    if (type(recevPubKey) ~= "number") or (recevPubKey < 1) then error("Invalid public key", 2) end
    if (type(sendPrivKey) ~= "number") or (sendPrivKey < 1) then error("Invalid private key", 2) end
    eMsg = package(PCrypt.RSA.crypt(PCrypt.RSA.crypt(str, sendPrivKey), recevPubKey), 128)
    
