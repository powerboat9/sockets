local tGet = {}

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
    self:checkAES()
    self.modem.transmit(self.channel, self.channel, {
        _program = "PSockets",
        _encrypt = "AES",
        to = to,
        from = self.ME
        port = port,
        msg = PCrypt.AES.crypt(msg, key),
    })
end

function tGet:sendPlain(to, msg)
    if type(msg) ~= "string" then error("Could not send type " .. type(msg), 2) end
    self:checkPlain()
    self.modem.transmit(self.channel, self.channel, {
        _program = "PSockets",
        
