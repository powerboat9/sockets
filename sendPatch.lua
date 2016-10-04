--Installs custom functions for encrypted messages
local dontPreventQueue, myKey = ...

local function verifyChannel(n)
    return type(n) == "number" and n >= 0 and n <= 65535
end

local function createConfig()
    local f = fs.open("/.pubKeys", "w")
    f.write("{}")
    f.close()
    return {}
end

local publicKeys = (function()
    local f = fs.open("/.pubKeys", "r")
    if f then
        local t = f.readAll()
        f.close()
        t = textutils.unserialize(t)
        if type(t) == "table" then
            for name, key in pairs(t) do
                if type(name) ~= "string" or name == "" or type(key) ~= "table" or type(key[1]) ~= "number" or key[1] == math.huge or key[1] < 1 or type(key[2]) ~= "number" or key[2] == math.huge or key[2] < 0 then
                    return createConfig()
                end
            end
            return t
        else
            return createConfig()
        end
    else
        return createConfig()
    end
end)()

local seenIDs = {timers = {}, check = {}}

local nativepullraw, nativequeue = _G.os.pullEventRaw, _G.os.queueEvent

local run = coroutine.wrap(function()
    while true do
        local e = {nativepullraw()}
        local t = os.time() + os.day * 24000
        if e[1] == "modem_message" and verifyChannel(e[3]) and verifyChannel(e[4]) and type(e[5]) == "table" and e[5]._pgram == "PSocket" and e[5].type = "secure_transmit" and type(e[5].msg) == "table" and publicKeys[e[5].from] and type(e[5].time) == "number" and e[5].time >= t and e[5].time <= (t + MSG_DELIVER_WINDOW) and e[5].msgID and tostring(e[5].msgID) and not seenIDs.check[e[5].msgID] then
            local comMsg = ""
            local isOk = true
            for _, part in ipairs(e[5].msg) do
                if type(part) ~= "number" or part >=  or part < 0 then
                    isOk = false
                    break
                end
                local ok, v = pcall(function() return PCrypt.RSA.encrypt(part, publicKeys[e[5].from]) end)
                if not ok then
                    isOk = false
                    break
                end
                while part > 0 do
                    comMsg = comMsg .. string.char(part % 256)
                    part = math.floor(part / 256) * 256
                end
            end
            if isOk and PCrypt.sha2.hash256(tostring(e[5].msgID):gsub("\\", "\\\\"):gsub(":", "\\:") .. ":" .. e[5].time .. ":" .. comMsg) == e[5].hash then
                seenIDs.check[e[5].msgID] = true
                seenIDs.timers[os.startTimer(MSG_DELIVER_WINDOW + 0.2)] = msgID
                nativequeue("secure_message", from, e[5].msg)
            end
        elseif e[1] == "timer" and seenIDs.timers[e[2]] then
            seenIDs.check[seenIDs.timers[e[2]]] = nil
            seenIDs.timers[e[2]] = nil
        end
    end
end)

run()

_G.os.pullEventRaw = function(s)
    while true do
        local e = {nativepullraw()}
        run(table.unpack(e))
        if not s or e[1] == s then
            return table.unpack(e)
        end
    end
end

if not dontPreventQueue then
    _G.os.queueEvent = function(...)
        if arg[1] == "secure_message" then
           error("Could not forage secure message event", 2)
        end
        return table.unpack(arg)
    end
end

local nativewrap = _G.peripheral.wrap
_G.secureWrap = function(s)
    if peripheral.getType(s) ~= "modem" then
        return nativewrap(s)
    else
        local t = peripheral.wrap(s)
        if not t then
            return
        end
        local oldTransmit = t.transmit
        t.transmit = function(snd, recv, msg)
            if 