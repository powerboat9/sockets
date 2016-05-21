local version = "BETA"

local mInterface = false
local pubKey, privKey

do
    local handle = fs.open("/.identity", "r")
    if handle then
        pubKey, privKey = handle.readLine(), handle.readLine()
        pubLey = isH(pubKey, PCrypt.RSA.hLen) and pubKey
        privKey = isH(privKey, PCrypt.RSA.hLen) and privKey
        handle.close()
    end
end

if not (pubKey and privKey) then
    pubKey, privKey = PCrypt.RSA.keygen()
    local handle = fs.open("/.identity", "w")
    handle.write(pubKey .. "\n" .. privKey)
    handle.close()
end

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
    function wrapMsg(self, to, port, key, msg, type, eType)
        local tMsg = tostring(tStamp) .. ": " .. msg
        local eMsg
        if eType = "RSA" then
            eMsg = PCrypt.RSA.crypt(tMsg, key)
        elseif eType ~= "NONE" then
            eType = "AES"
            eMsg = PCrypt.AES.crypt(tMsg, key)
        end
        local tStamp = os.time() + os.day() * 24000
        local newMsg = {
            _pgram = "psockets v" .. version,
            crypt = eType,
            from = pubKey,
            to = to,
            port = port,
            msg = eMsg,
            checksum = PCrypt.SHA3(tMsg),
            type = type
        }
        self:rawSend(newMsg)
    end,
    function unwrap(msg, promiscuous, filterPort)
        if msg._pgram ~= ("psockets v" .. version) then return false end
        if not (promiscuous or (msg.to == pubKey)) then return false end
        
    function initiate(self, modem, port, to, othPubKey)
        local proof = convert.ntoh(math.random(1, 16 ^ 8))
        self:wrapMsg(to, port, to, "CONNECT", "string", "RSA")
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
