local sockets = corouting.create(loadfile(shell.getRunningProgram():sub(1, -5) .. "socket"))
local user = coroutine.create(loadstring("/rom/programs/shell"))

local modem = assert(peripheral.find("modem"), "Could Not Find Modem")
modem.open(rednet.CHANNEL_BROADCAST)

local packets = {
    displayMe = function(ip, socket, protocol)
        return {
            check = "Yes, this is powerboat9's socket program",
            command = "connecting",
            data = {
                phase = "display",
                me = {
                    ip = ip,
                    socket = socket,
                    protocol = protocol
                }
            }
        }
    end,
    attemptConnect = function
}

local connections = {}

function verifyPacket(p)
    if not ((type(p) == "table") and (type(p.data) == "table") and (type(p.data.me) == "table") and (type(p.data.me.ip) == "number")) then return false end
    if not (type(p.me.socket) == "string") and (#socket == 16) then return false end
    for _, v in gsub(p.me.socket) do
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
                        ip = data.me.ip
                    modem.transmit()
    coroutine.resume()
