local tGet = {}
local tempIDs = {}

function tGet:check()
    if not self.modem then
        local wireless = peripheral.find("modem", function(name, obj) return obj.isWireless end)
        local wired = peripheral.find("modem", function(name, obj) return not obj.isWireless() end)
        self.modem = wireless or wired or (return false)
    end
    if not self.me then
        local h = fs.open("/.ids/default", "r")
        if h then
            self.me = h.readLine():gsub("%s", "")
            self.me = self.me and (self.me ~= "")
        end
        self.me = self.me or "ID_" .. os.getComputerID()
    end
end

function tGet:checkRSA()
    self:check()
    local id = fs.open("/.ids/default", "r")
    if not (self.privKey and self.pubKey) then
        self.privKey, self.pubKey = PCrypt.RSA.keygen()
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

function tGet:sendAES(to, msg, key)
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
