local sockets = corouting.create(loadfile(shell.getRunningProgram():sub(1, -5) .. "socket"))
local user = coroutine.create(loadstring("/rom/programs/shell"))

math.randomseed(os.time() + os.day() * 24000)

do
    if not ((type(_G.sha) == "table") and (type(_G.sha.hash256) == "function")) then
        error("I need an api (SHA-2 at \"github.com/powerboat9\")")
    end
end

function genRandHash(length)
    local s = ""
    for i = 1, length do
        local rand = math.random(1, 16)
        s = s .. ("0123456789abcdef"):sub(rand, rand)
    end
    return s
end

function gen

local modem = assert(peripheral.find("modem"), "Could Not Find Modem")
modem.open(rednet.CHANNEL_BROADCAST)

local myIP = 65536 + os.getComputerID()

local packets = {
    displayMe = function(socket, protocol, myID)
        return {
            check = "Yes, this is powerboat9's socket program",
            command = "connecting",
            data = {
                phase = "display",
                me = {
                    ip = myIP,
                    socket = socket
                },
                protocol = protocol
            },
            myID = myID
        }
    end,
    attemptConnect = function(otherIP, otherSocket, mySocket)
        return {
            check = "Yes, this is powerboat9's socket program",
            command = "connecting",
            data = {
                phase = "attemptConnection",
                me = {
                    ip = myIP,
                    socket = mySocket
                },
                to = {
                    ip = otherIP,
                    socket = otherSocket
                }
            }
        }
    end
}

local connections = {}

function verifyPacket(p)
    if not ((type(p) == "table") and (type(p.data) == "table") and (type(p.data.me) == "table") and (type(p.data.me.ip) == "number") and (type(p.data.to) == "table") and (p.data.to.ip == myIP)) then return false end
    if not ((type(p.data.me.socket) == "string") and (#p.data.me.socket == 16) and (type(p.data.to.socket) == "string") and (#p.data.to.socket == 16)) then return false end
    for _, v in gsub(p.data.me.socket, ".") do
        local num = string.byte(v)
        if not (((num >= 97) and (num <= 122)) or ((num >= 48) and (num <= 57))) then return false end
    end
    for _, v in gsub(p.data.to.socket, ".") do
        local num = string.byte(v)
        if not (((num >= 97) and (num <= 122)) or ((num >= 48) and (num <= 57))) then return false end
    end
    return true
end

while true do
    event = {os.pullEvent()}
    coroutine.resume(user, unpack(event))
    if event[1] == "modem_message" then
        local msg, channel = event[4], event[3]
        if verifyPacket(msg) then
            if msg.command == "connecting" then
                if (msg.data.phase = "display") and ((not attempHandshake) or attemptHandshake(msg)) then
                    table.insert(connections, {
                        other = {
                            ip = msg.data.me.ip,
                            socket = msg.data.me.socket
                        },
                        phase = "awaitingConfirm"
                    })
                    modem.transmit(channel, channel, attemptConnect(msg.data.me.ip, msg.data.me.socket, msg.data.to.socket))
    coroutine.resume()
