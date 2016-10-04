math.randomseed(os.time()); math.random(); math.random()

local hash = PCrypt.hash.sha256

local sign = PCrypt.encrypt.RSA.encrypt

local timeout = 5
local msgIDs = {}

local function spairs(t, k) --super pears/pairs
    if type(t) ~= "table" then
        error("Expected table", 2)
    end
    if type(k) == "number" and t[k] ~= nil then
        return k + 1, k, t[k]
    else
        return next(t, k)
    end
end

local cron = {}
do
    local f = fs.open("cron.lua", "r")
    if not f then
        error("Could not load cron file", 0)
    end
    local ok, err = pcall(load(f.readAll(), "loadCron", "t", cron))
    if not ok then
        local prtErr = tostring(err)
        prtErr = prtErr and (": " .. prtErr) or ""
        error("Could not load cron" .. prtEr, 0)
    end
end

local publicKeys = {}
local privateKeys = {}

local defaultInterface = {"wlan", 0}
local interfaces = {}
function addInterface(side)
    if peripheral.getType(side) == "modem" then
        local prefix = peripheral.call(side, "isWireless") ? "wlan" : "eth"
        interfaces[prefix] = interfaces[prefix] or {}
        local n = #interfaces[prefix] + 1
        interfaces[prefix][n] = {modem = peripheral.wrap(side), connections = {}, side = side}
        return prefix, n
    else
        return false
    end
end

function findInterface(side)
    if type(side) ~= "string" or peripheral.getType(side) ~= "modem" then
        return false
    end
    for prefix in pairs(interfaces) do
        for n in pairs(interfaces[prefix]) do
            local interface = interfaces[prefix][n]
            if interface.side == side then
                return interface, prefix, n
            end
        end
    end
    return false
end

local function deleteInterface(prefix, n)
    if not interfaces[prefix][n] then
        return false
    end
    for connectionID, connection in spairs(interfaces[prefix][n].connections) do
        connection:terminate(

local function isValidPort(port)
    return type(port) == "number" and port >= 0 and port <= 65535
end

local isValidChannel = isValidPort

local function isValidAddress(address)
    return (type(address) == number and address ~= math.huge) or (type(address) == "string" and address ~= "")
end

local getSign
do
    local function escapeVals(...)
        local ret = {}
        for i = 1, #args do
            ret[i] = args[i]:gsub("$", "$$"):gsub(":", " $-")
        end
        return ret
    end
    getSign = function(msg)
        if isValidAddress(msg.to) and isValidAddress(msg.from) and type(msg.stamp) == "number" and type(msg.port) == "number" then
            return table.concat(es, ":"
        

local function verifyMsg(msg, address, port)
    assert(isValidPort(port) or port == nil, "Invalid port")
    assert(isValidAddress(address) or address == nil, "Invalid address")
    if type(msg) ~= "table" or msg._pgram ~= "PSocket" or not isValidPort(msg.port) or (port and msg.port ~= port) or not isValidAddress(msg.to) or (address and msg.to ~= address) or (msg.retPort ~= nil and not isValidPort(msg.retPort)) or not isValidAddress(msg.from) or type(msg.stamp) ~= "number" then
        return false
    end
    if not msg.isSecure or 
end

local function verifyMsgEvent(e, address, port)
    if e[1] ~= "modem_message" or not isValidSide(e[2]) or not isValidChannel(e[3]) or not isValidChannel(e[4]) then
        return false
    end
    return verifyMsg(e[5], address, port)
end

local function makeMsgSecure(self, msg)
    if isValidAddress(msg.to) and isValidAddress(msg.from) and type(msg.stamp) == "number" and type(msg.port) == "number" then
        msg.check = sign(tostring(msg.to):gsub("$", "$$"):gsub(":", "$1") .. ":" .. tostring(msg.from):gsub("$", "$$"):gsub(":", "$1") .. ":" .. msg.port)
        msg.isSecure = true
        return true
    else
        return false
    end
end

local function _CONNECTION_send(self, msg)
    if self.stage == 0 then
        error("Socket unprepaired", 2)
    elseif type(msg) == "table" and self.autofill then
        msg._pgram = msg._pgram or "PSocket"
        msg.to, msg.from = msg.to or self.to, msg.from or self.from
        msg.port, msg.connectionID = msg.port or self.other.recvPort, msg.connectionID or self.other.connectionID
        msg.stamp = os.time() + os.day() * 24000
        if self.isSecure and not self:makeMsgSecure(msg) then
            error("Could not continue with secure msg", 2)
        end
    end
    self.interface.modem.transmit(self.other.recvChannel, self.this.recvChannel, msg)
end

local function _CONNECTION_terminate(self)
    self.

local function continueConnection(e)
    if not verifyMsgEvent(e) or e[5].type ~= "startConnection" then
        return false
    end
    local interface = findInterface(e[2])
    if not interface then
        return false
    end
    local myConnectionID = #connections + 1
    local connection = {
        other = {
            connectionID = e[5].myConnectionID,
            recvChannel = e[4],
            recvPort = e[5].retPort or e[5].port
        },
        this = {
            connectionID = myConnectionID,
            recvChannel = e[3],
            recvPort = e[5].port
        },
        to = e[5].from,
        from = e[5].to,
        interface = interface,
        send = _CONNECTION_send,
        autofill = true,
        stage = 1,
        t = os.startTimer(timeout)
    }
    if e[5].isSecure then --TODO
    connection:send({
        type = "okConnection",
        myConnectionID = connection.this.connectionID
     })
     interface.connections[myConnectionID] = connection
     return connection
end

local startingConnections = {}
function startConnection(sendChannel, recvChannel, to, from, sendPort, recvPort)
    if not (isValidChannel(sendChannel) and isValidChannel(recvChannel) and isValidAddress(to) isValidAddress(from) and and isValidPort(sendPort) and isValidPort(recvPort)) then
        return false
    end
    local interface = interfaces[defaultInterface[1]]
    if interface then
        interface = interface[defaultInterface[2]]
    end
    if not interface then
        return false
    end
    local connection = {
        this = {
            connectionID = math.random(0, 65535),
            recvChannel = recvChannel,
            recvPort = recvPort
        },
        other = {
            connectionID = false,
            recvChannel = sendChannel,
            recvPort = sendPort
        },
        to = to,
        from = from,
        interface = interface,
        send = _CONNECTION_send,
        autofill = true,
        stage = 0,
        t = os.startTimer(timeout)
    }
    interface.connections[#interface.connections + 1] = connection
    return true
end

local function completeConnection(e)
    if not verifyMsgEvent(e) or e[5].type ~= "okConnection" then
        return false
    end
    for prefix in pairs(interfaces) do
        for i = 1, #interfaces[

local function updateConnectionTimers(t)
    for 

local function broadcastKeepAlives(interface)
    for prefix in pairs(interfaces) do
        for n in pairs(interfaces[prefix]) do
            for _, connection in ipairs(interfaces[prefix][n].connections) do
                if connection.stage == 1 then
                    connection:send({
                        type = "keepAlive"
                    })
                end
            end
        end
    end
end

local routines = {secure = {}, list = {}}
function genListen(port, address)
    assert(isValidPort(port), "Invalid port")
    assert(isValidAdress(address) or (address == nil), "Invalid address")
    local n = #routines + 1
    routines.list[n] = coroutine.create(function()
        while true do
            local e = {coroutine.yield(false, "getData")}
            local interface = findInterface(e[2])
            if e[1] == "timer" then
                updateTimer(e[2])
                updateConnectionTimers(e[2])
                cron.update(e[2])
            elseif verifyMsgEvent(e, port, address) and interface then
                if e[5].type == "msg" then
                    coroutine.yield(true, "msg", e[5].msg, e[5].address)
                elseif e[5].type == "connect" then
                    local con = continueConnection(e)
                    if con then
                        coroutine.yield(true, "establishedCon", con)
                    else
                        coroutine.yield()
                    end
                elseif e[5].type == "terminateConnection" then
                    if fi
