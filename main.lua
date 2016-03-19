local sockets = corouting.create(loadfile(shell.getRunningProgram():sub(1, -5) .. "socket"))
local user = coroutine.create(loadstring("/rom/programs/shell"))

local modem = assert(peripheral.find("modem"), "Could Not Find Modem")
modem.open(rednet.CHANNEL_BROADCAST)

local packets = {
    displayMe = function(ip, socket, protocol)
        return {
            check = "Yes, this is powerboat9's socket program",
            command = "connecting",
            data = {phase = "display"}
        }
}

while true do
    event = {os.pullEvent()}
    coroutine.resume(user, unpack(event))
    if event[1] == "modem_message" then
        local msg, channel = event[4], event[3]
        if (type(msg) == "table") and (msg.check == "Yes, this is powerboat9's socket program") and (type(msg.command) == "string") and (type(msg.data) == "table") then
            if msg.command == "connecting" then
                if (msg.data.phase = "display") and (not attempHandshake) or attemptHandshake(msg) then
                    modem.transmit()
    coroutine.resume()
