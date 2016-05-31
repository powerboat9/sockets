local tGet = {}
local tempIDs = {}

function tGet:check()
    if not self.modem then
        local wireless = peripheral.find("modem", function(name, obj) return obj.isWireless end)
        local wired = peripheral.find("modem", function(name, obj) return not obj.isWireless() end)
        self.modem = wireless or wired or (return false)
    end
end

function tGet:checkRSA()
    tGet:check()
    if not (self.privKey and self.pubKey) then
        local h = fs.open("/.ids/default", "r")
        if h then
            self.pubKey = h.readLine():gsub("%s", "")
            self.pubKey = self.pubKey and PCrypt.convert.isH(self.pubKey, 512)
            self.privKey = h.readLine():gsub("%s", "")
            self.privKey = self.privKey and PCrypt.convert.isH(self.privKey, 512)
            if self.pubKey and self.privKey and (PCrypt.RSA.crypt(PCrypt.RSA.crypt("Comment me out for problems!", self.pubKey), self.privKey) == "Comment me out for problems!") then
                self.pubKey, self.privKey = false, false
            end
        end
    end
    if not (self.privKey and self.pubKey) then
        self.privKey, self.pubKey = PCrypt.RSA.keygen()
        local h = fs.open("/.ids/default", "w")
        h.write(self.pubKey .. "\n" .. self.privKey)
        h.close()
    end
end

function tGet:sendRSA(to, msg, port)
    if type(msg) ~= "string" then error("Could not send type " .. type(msg)) end
    self:checkRSA()
    self.modem.transmit(self.channel, self.channel, {
        _program = "PSockets"
        _encrypt = "RSA"
        to = to,
        from = self.pubKey,
        port = port,
        msg = PCrypt.RSA.crypt(PCrypt.RSA.crypt(msg, to), self.privKey)
    })
end

function tGet:sendAES(to, from, msg, key)
    if type(msg) ~= "string" then error("Could not send type " .. type(msg), 2) end
    self:check()
    self.modem.transmit(self.channel, self.channel, {
        _program = "PSockets",
        _encrypt = "AES",
        to = to,
        from = self.me
        port = port,
        msg = PCrypt.AES.crypt(msg, key),
    })
end

function tGet:sendPlain(to, msg)
    if type(msg) ~= "string" then error("Could not send type " .. type(msg), 2) end
    self:check()
    self.modem.transmit(self.channel, self.channel, {
        _program = "PSockets",
        _encrypt = "plain",
        _to = to,
        _from = self.me,
        _msg = msg,
    })
end
