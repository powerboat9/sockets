math.randomseed(os.time()); math.random(); math.random()
local function log(msg) end

local function canCall(v) --"Tail recursion is it's own reward" -xkcd
    if type(v) == "function" then
        return true
    elseif type(v) == "table" and getmetatable(v) then
        return canCall(getmetatable(v).__call)
    else
        return false
    end
end

local interfaces = {}
function addInterface(side)
    if peripheral.getType(side) == "modem" then
        local prefix = peripheral.call(side, "isWireless") ? "wlan" : "eth"
        local n = #interfaces[prefix]
        if not interfaces[prefix] = interfaces[prefix] or {}
        interfaces[prefix][n] = {modem = peripheral.wrap(side), connections = {}, side = side}
        return prefix .. n
    else
        return false
    end
end

local function findInterface(side)
    local isOk = false
    for _, checkSide in ipairs(rs.getSides()) do
        if side == checkSide then
            isOk = true
            break
        end
    end
    if not isOk then
        return false
    end
    for prefix in pairs(interfaces) do
        for n in pairs(interfaces[prefix]) do
            local interface = interfaces[prefix][n].side
            if interface.side == side then
                return interface
            end
        end
    end
    return false
end

local verifyMsg(e, port, address)
    assert(isValidPort(port) or port == nil, "Invalid port")
    assert(isValidAddress(address) or address == nil, "Invalid address")
    return e[1] == "modem_message" and type(e[5]) == "table" and e[5]._pgram == "PSocket" and (e[5].port == port or not port) and (e[5].to == address or not address) and (isValidPort(e[5].retPort) or e[5].retPort == nil) and isValidAddress(e[5].from) and isValidMsgId(e[5].msgID)
end

local function updateTimer(t)
    if callbacks[t] then
        callbacks[t]()
    end
end

local callbacks = {}
local setupCallback(funct, timesLeft, dontBreak)
    assert(canCall(funct), "Invalid function")
    timesLeft = timesLeft or 9
    assert(type(timesLeft) == "number", "Invalid callback number")
    local t = os.startTimer(1)
    callbacks[t] = function()
        local ok, err = pcall(funct)
        local _, _, id = tostring(funct):find("^[^ ]* (.*)")
        if not ok or dontBreak then
            log("Callback " .. id .. " failed, " .. (timesLeft == 0 and "no" or timesLeft) .. " tries left")
            if timesLeft < 0 then
                log("Failed to call a function " .. timesLeft .. " times")
            elseif timesLeft > 0 then
                setupCallback(funct, timesLeft - 1, dontBreak)
            end
        else
            log("Callback " .. id .. " was successful")
        end
    end
    return t
end

local verifyConnection

local function sndBack(e)
    local t
    t = setupCallback(function()
        if verifyMsg(e) then
            local ok = pcall(function() peripheral.call(e[2], "transmit", e[4], e[3], {
                type = "verify",
                port = e[5].retPort or e[5].port,
                to = e[5].from,
                from = e[5].to,
                msgID = e[5].msgID
            }) end)
            if not ok
                updateTimer(t)
            end
        else
            updateTimer(t)
        end
    end, 9)
end

local function genTransmitBackFunction(e)
    if not verifyMsg(e) then
        return false
    end
    return function(msg)
        e[

local function startConnection(e)
    if not verifyMsg(e) or e[5].type ~= "startConnection" then
        return false
    end
    local interface = findInterface(e[2])
    if not interface then
        return false
    end
    local connection = {
        otherConnectionID = e[5].connectID,
        transmit = genTransmitBackFunction(e)
    }
    sendBack(e, {
        _pgram = "PSocket",
        type = "okConnection",
        connectID = e[5].connectID)

local function broadcastKeepAlives(interface)
    for prefix in pairs(interfaces) do
        for n in pairs(interfaces[prefix]) do
            for _, connection in ipairs(interfaces[prefix][n].connections) do
                connection.send({
                    _pgram = "PSocket",
                    type = "keepAlive"
                })
            end
        end
    end
end

function genListen(port, address)
    assert(isValidPort(port), "Invalid port")
    assert(isValidAdress(address) or (address == nil), "Invalid address")
    return coroutine.create(function()
        while true do
            local e = {os.pullEventRaw()}
            if e[1] == "timer" then
                updateTimer(e[2])
            elseif verifyMsg(e, port, address) then
                if e[5].type == "msg" then
                    coroutine.yield(true, "msg", e[5].msg, e[5].address)
                elseif e[5].type == "connect" then
                    local connection = {
                        to = 
