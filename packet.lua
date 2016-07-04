local version = "0.1.0-developement"
local CHANNEL_SOCKETS = 60000

local function verifyPacket()

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
end

local function getRawPackets(str, to, from, size, _funct) --_funct is not intended for users
    if not PCrypt.convert.isH(str) then
        error("Message is not a hexadecimal string", 2)
    end
    if type(size) ~= "number" then error("Size is not a number", 2) end
    if size < 1 then error("Size cannot be less than 1", 2) end
    _funct = ((type(_funct) ~= "function") and _funct) or (function(v) return v end)
    local ret = {}
    local divMSG = package(str, size * 2)
    for k, v in ipairs(divMSG) do
        ret[k] = {
            _pgram = " powerboat9:sockets",
            _version = version,
            to = to,
            from = from,
            msg = v
            msgID = PCrypt.convert.randH(32)
        }
        _funct(ret[k])
    end
    bind(ret)
    return ret
end

local function getAESPackets(str, to, from, key)
    if not PCrypt.convert.isH(str) then
        error("Message not a hexadecimal string", 2)
    end
    if not PCrypt.convert.isH(key, 256) then
        error("Key is not a 256 byte hexadecimal string", 2)
    end
    return getRawPackets(str, to, from, 128, function(v)
        v.msg = PCrypt.AES.crypt(v.msg, key)
        v.encryption = "AES"
    end)
end

/*local function getRSAPackets(str, to, from, recevPubKey, sendPrivKey)
    if type(str) ~= "string" then
        error("Message is not a string", 2)
    end
    if (type(recevPubKey) ~= "number") or (recevPubKey < 1) then error("Invalid public key", 2) end
    if (type(sendPrivKey) ~= "number") or (sendPrivKey < 1) then error("Invalid private key", 2) end
    eMsg = package(PCrypt.RSA.crypt(PCrypt.RSA.crypt(str, sendPrivKey), recevPubKey), 128)*/

local function get(eventList, connections)
    local e, _, to, from, msg, dist = table.unpack(eventList)
    if (e == "modem_message") and (to == CHANNEL_SOCKETS) and (from == CHANNEL_SOCKETS) then
