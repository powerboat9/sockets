return {
    function transmit(modem, port, msg, to, from, key, timestamp)
        timestamp = timestamp or (os.time() + (os.day() * 24000))
        local hash = SHA.hash256(("%s:%s:%s:%s:%s"):format(to, from, timestamp, key, msg))
        modem.transmit(rednet.CHANNEL_BROADCAST, rednet.CHANNEL_BROADCAST, {
            msg = msg,
            to = to,
            from = from,
            timestamp = timestamp,
            port = port,
            hash = hash
        })
    end,
    function interpret(port, msg, keytabel)
        if (type(msg) == "table") and (type(msg.msg) == "string") and (type(msg.to) == "number") and (type(msg.from) == "number") and (type(msg.timestamp) == "number") and (type(msg.port) == "number") then
            if SHA.hash256(("%s:%s:%s:%s:%s"):format(msg.to, msg.from, msg.timestamp, keytable[msg.from], msg.msg)) == msg.hash then
                return msg, true
            end
            return msg, false
        end
        return false
    end
}
