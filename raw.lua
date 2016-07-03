local tGet = {}
local tempIDs = {}

local function hCheck(str, len)
    if len and (#str ~= len) then return false end
    if str ~= str:gsub("[^0-9a-fA-F]", "") then return false end
    return true
end

function tGet:check()
    if not self.modem then
        local wireless = peripheral.find("modem", function(name, obj) return obj.isWireless end)
        local wired = peripheral.find("modem", function(name, obj) return not obj.isWireless() end)
        self.modem = wireless or wired or (return false)
        return true
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
        local defID = "/.ids/default"
        self.privKey, self.pubKey = PCrypt.RSA.keygen()
        if fs.exists(defID) and (not fs.isDir(defID)) then
            local fr = fs.open(defID", "r")
            local pub, pri = fr.readLine(), fr.readLine()
            if 
        local h = fs.open(defID, "w")
        h.write(self.pubKey .. "\n" .. self.privKey)
        h.close()
    end
end

function tGet:sendRSA(to, msg, port, order, done)
    if type(msg) ~= "string" then error("Could not send type " .. type(msg)) end
    if #msg > 32 then error("Could not send msg of length " .. #msg, 2) end
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

function tGet:sendAES(to, msg, port, key, order, done)
    if type(msg) ~= "string" then error("Could not send type " .. type(msg), 2) end
    if #msg > 32 then error("Could not send msg of length " .. #msg, 2) end
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
    if #msg > 32 then error("Could not send msg of length " .. #msg, 2) end
    self:check()
    self.modem.transmit(self.channel, self.channel, {
        _program = "PSockets",
        _encrypt = "plain",
        _to = to,
        _from = self.me,
        _msg = msg,
    })
end

function tGet:recv(port)
    
