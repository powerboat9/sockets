local tGet = {}

function tGet:sendRSA(to, msg, port)
    self:check()
    if type(msg) ~= "string" then error("Could not send type " .. type(msg)
    self.modem.transmit(self.channel, self.channel, {
        _program = "PSockets"'
        _encrypt = "RSA"
        to = to,
        from = self.pubKey,
        port = port,
        msg = PCrypt.RSA.crypt(PCrypt.RSA.crypt(msg, to), self.privKey)
    })
end

function tGet:sendAES(msg, key)
