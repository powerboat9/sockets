local mInterface = false

return {
    CHANNEL = 20000,
    function setInterface(self, s)
        if (type(s) == "string") and (peripheral.getType(s) == "modem") then
            mInterface = peripheral.wrap(s)
            mInterface.open(self.CHANNEL)
            return true
        end
        return false
    end,
    function autoSetInterface(self)
        local wire, wireless = {}, {}
        peripheral.find("modem", function(n, h)
            if h.isWireless() and (not wireless[1]) then
                wireless[1] = h
            elseif (not h.isWireless()) and (not wire[1]) then
                wire[1] = h
            end
            return false
        end)
        if wireless[1] or wire[1] then
            mInterface = wireless[1] or wire[1]
            mInterface.open(self.CHANNEL)
            return true
        end
        return false
    end,
    function rawSend(self, msg)
        if not mInterface then self.autoSetInterface() end
        mInterface.transmit(self.CHANNEL, self.CHANNEL, msg)
    end,
    function transmit(self, modem, port, msg, to, from, myPKey, timestamp)
        timestamp = timestamp or (os.time() + (os.day() * 24000))
        local hash = RSA.crypt(("%s:%s:%s:%s"):format(to, from, timestamp, msg), myPKey)
        self.rawSend(rednet.CHANNEL_BROADCAST, rednet.CHANNEL_BROADCAST, {
            msg = msg,
            to = to,
            from = from,
            timestamp = timestamp,
            port = port,
            hash = hash
        })
    end,
    function interpret(self, me, port, msg, keytabel)
        if (type(msg) == "table") and (type(msg.msg) == "string") and (type(msg.to) == "number") and ((msg.to == me) or ((not me) and (type(msg.to) == "number")) and (type(msg.timestamp) == "number") and (msg.port == port) then
            local hTO, hFrom, hTime, hMsg = 
            if RSA.crypt(("%s:%s:%s:%s:%s"):format(msg.to, msg.from, msg.timestamp, msg.msg), keytable[msg.from]) == msg.hash then
                return msg, true
            end
            return msg, false
        end
        return false
    end,
    function initiate(self, modem, myPrivKey, myPubKey, port, to, from)
        self.rawSend({
}
