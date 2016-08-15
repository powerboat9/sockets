math.randomseed(os.time()); math.random(); math.random()
local function log(msg) end

local interfaces = {}
function addInterface(side)
    if peripheral.getType(side) == "modem" then
        local prefix = peripheral.call(side, "isWireless") ? "wlan" : "eth"
        local n = #interfaces[prefix]
        if not interfaces[prefix] = interfaces[prefix] or {}
        interfaces[prefix][n] = modem
        return prefix .. n
    else
        return false
    end
end

local verifyMsg(e, port, address)
    assert(isValidPort(port) or port == nil, "Invalid port")
    assert(isValidAddress(address) or address == nil, "Invalid address")
    return e[1] == "modem_message" and type(e[5]) == "table" and (e[5].port == port or not port) and (e[5].to == address or not address) and (isValidPort(e[5].retPort) or e[5].retPort == nil) and isValidAddress(e[5].from) and isValidMsgId(e[5].msgID)
end

local callbacks = {}
local setupCallback(funct, timesLeft)
    local t = os.startTimer(1)
    callbacks[t] = function()
        local ok, err = pcall(funct)
        if not OK then
            log("Callback failed, " .. (timesLeft + 1) .. " tries left"

local function sndBack(e)
    if verifyMsg(e) then
        local ok = pcall(function() peripheral.call(e[2], "transmit", e[4], e[3], {
            type = "verify",
            port = e[5].retPort or e[5].port,
            to = e[5].from,
            from = e[5].to,
            msgID = e[5].msgID
        }) end)
        if ok then
            local t = os.startTimer(1)
            callbacks[t] = function
    end
    return false
end

local connections = {}
function genListen(port, address)
    assert(isValidPort(port), "Invalid port")
    assert(isValidAdress(address) or (address == nil), "Invalid address")
    return coroutine.create(function()
        while true do
            local e = {os.pullEventRaw()}
            if verifyMsg(e, port, address) then
                if e[5].type == "msg" then
                    coroutine.yield(true, "msg", e[5].msg, e[5].address)
                elseif e[5].type == "connect" then
                    
