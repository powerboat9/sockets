math.randomseed(os.time()); math.random(); math.random()

local timeout = 5
local msgIDs = {}

local cron = {}
do
    local f = fs.open("cron.lua", "r")
    local ok, err= pcall(load(f.readAll(), "loadCron", "t", cron))
    if not ok then
        local prtErr = tostring(err)
        prtErr = prtErr and (": " .. prtErr) or ""
        error("Could not load cron" .. prtEr, 0)
    end
end

local defaultInterface = {"wlan", 0}
local interfaces = {}
function addInterface(side)
    if peripheral.getType(side) == "modem" then
        local prefix = peripheral.call(side, "isWireless") ? "wlan" : "eth"
        if not interfaces[prefix] = interfaces[prefix] or {}
        local n = #interfaces[prefix] + 1
        interfaces[prefix][n] = {modem = peripheral.wrap(side), connections = {}, side = side}
        return prefix, n
    else
        return false
    end
end

function findInterface(side)
    for _, v in ipairs(rs.getSides()) do
        if v == side then
            isOK = true
        end
    end
    if not isOk then
        return false
    end
    for prefix in pairs(interfaces) do
        for n in pairs(interfaces[prefix]) do
            local interface = interfaces[prefix][n]
            if interface.side == side then
                return interface
            end
        end
    end
    return false
end

local function isValidPort(port)
    return type(port) == "number" and port >= 0 and port <= 65535
end

local isValidChannel = isValidPort

local function isValidAddress(address)
    return (type(address) == number and address ~= math.huge) or (type(address) == "string" and address ~= "")
end

local function isValidMsgID(id)

local function verifyMsg(e, address, port)
    assert(isValidPort(port) or port == nil, "Invalid port")
    assert(isValidAddress(address) or address == nil, "Invalid address")
    return e[1] == "modem_message" and isValidSide(e[2]) and isValidChannel(e[3]) and isValidChannel(e[4]) and type(e[5]) == "table" and e[5]._pgram == "PSocket" and isValidPort(e[5].port) and (e[5].port == port or not port) and isValidAddress(e[5].to) and (e[5].to == address or not address) and (isValidPort(e[5].retPort) or e[5].retPort == nil) and isValidAddress(e[5].from) and isValidMsgId(e[5].msgID)
end

local function _CONNECTION_send(self, msg)
    if self.stage == 0 then
        error("Socket unprepaired", 2)
    elseif type(msg) == "table" and self.autofill then
        msg._pgram = msg._pgram or "PSocket"
        msg.to, msg.from = msg.to or self.to, msg.from or self.from
        msg.port, msg.connectionID = msg.port or self.other.recvPort, msg.connectionID or self.other.connectionID
    end
    self.interface.modem.transmit(self.other.recvChannel, self.this.recvChannel, msg)
end

local function continueConnection(e)
    if not verifyMsg(e) or e[5].type ~= "startConnection" then
        return false
    end
    local interface = findInterface(e[2])
    if not interface then
        return false
    end
    local myConnectionID = math.random(4294967295)
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
    connection:send({
        type = "okConnection",
        myConnectionID = connection.this.connectionID
     })
     interface.connections[#connections + 1] = connection
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
    if not verifyMsg(e) or e[5].type ~= "okConnection" then
        return false
    end
    for prefix in pairs(interfaces) do
        for 

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

function genListen(port, address)
    assert(isValidPort(port), "Invalid port")
    assert(isValidAdress(address) or (address == nil), "Invalid address")
    return coroutine.create(function()
        while true do
            local e = {os.pullEventRaw()}
            if e[1] == "timer" then
                updateTimer(e[2])
                updateConnectionTimers(e[2])
                cron.update(e[2])
            elseif verifyMsg(e, port, address) then
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
                    if connect
