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
            if PCrypt.RSA.crypt(("%s:%s:%s:%s:%s"):format(msg.to, msg.from, msg.timestamp, msg.msg), keytable[msg.from]) == msg.hash then
                return msg, true
            end
            return msg, false
        end
        return false
    end,
    function initiate(self, modem, myPrivKey, myPubKey, port, to, from, othPubKey)
        local proof = convert.ntoh(math.random(1, 16 ^ 8))
        self.rawSend({
            _pgram = "p_sockets",
            type = "initiate",
            to = to,
            from = from,
            proof = proof,
            key = PCrypt.RSA.crypt(PCrypt.genHex(1024), othPubKey)
        })
        local msg
        do
            local timer = os.startTimer(5)
            while true do    
                local e, timeID
                e, timeID, _, _, msg = os.pullEvent()
                if (e == "timer") and (timeID = timer) then
                    return false, "Could Not Connect"
                elseif (type(msg) == "table") and (msg._pgram == "p_sockets") and (msg.type == "accept") and (msg.from == to) and convert.isH(msg.verif, 8) and convert.isH(msg.secret, 8) and (PCrypt.RSA.crypt(msg.verify, othPubKey) == proof) then
                    break
                end
            end
        end
        
}
