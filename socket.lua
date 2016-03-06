local allowWired = ...

math.randomseed(os.time())
math.random()
math.random()

local modem = assert(peripheral.find("modem", function(name, obj)
    return obj.isWireless() or allowWired
end), "Could Not Find Modem")

local sockets = {}

function randomText()
    local randTxt = ""
    local randomNum = nil
    for i = 1, 8 do
        randomNum = math.random(1, 16)
        randTxt = randTxt .. ("0123456789abcdef"):sub(randomNum, randomNum)
    end
    return randTxt
end

local statusEnum = {
    NONE = {},
    TERMINATE = {},
    KEEPALIVE = {},
    TRANSMIT = {}
}

function createSocket()
    local returnSocket = {}
    returnSocket.data = ""
    returnSocket.lastTimeRecived = -1
    returnSocket.timeOutTime = 10
    returnSocket.allowPing = true
    returnSocket.terminating = false
    returnSocket.events = {
        death = function() end, --self, (0 - done, 1 - thisForceClose, 2 - otherForceClose)
        message = function() return true end, --self, header, data, body
        asked = function() end, --self, header, data, body
        invalidHeader = function() return statusEnum.TERMINATE end --self, header, data, body
    }
    returnSocket.load = function(self, msg)
        if self.terminating then
            self.events.death(self)
            return statusEnum.TERMINATE
        end
        local header = ""
        local data = ""
        local body = ""
        do
            local sep = msg:find(":")
            local sep2 = msg:find(":")
            header = msg:sub(1, sep - 1)
            data = msg:sub(sep + 1, sep2 - 1)
            body = msg:sub(sep2 + 1)
            if header = " " then
                header = ""
            end
            if data = " " then
                data = ""
            end
            if body = " " then
                body = ""
            end
        end
        do
            local dataValues = {}
            for k, v in data:gmatch("([^|]*)|([^|]*)#?") do
                dataValues[k] = v
            end
            data = dataValues
        end
        if not self.events.message(self, header, data, body) then
            return statusEnum.NONE
        end
        if header = "forceClose" then
            self.events.death(self, 2)
            return statusEnum.TERMINATE
        elseif header = "data" then
            self.data = self.data .. body
            if data.keepAlive then
                return statusEnum.KEEPALIVE
            else
                return statusEnum.TERMINATE
            end
        elseif header = "askData" then
            return statusEnum.TRANSMIT, self.events.asked(self, header, data, body)
        elseif header = "ping" then
            if self.allowPing then
                return statusEnum.TRANSMIT, "pong: : "
            end
        elseif header = "pong" then
        else
            return self.events.invalidHeader(self, header, data, body)
        end
    end
    return returnSocket
end

function removeSocket(id)
    sockets[id].terminating = true
    (sockets[id]):load()
    sockets[id] = nil
end

while true do
    local command, data = coroutine.yield()
    if command == "registerSocket" then
        local newId = ""
        while true do
            newId = randomText()
            if not sockets[newId] then
                break
            end
        end
        local newSocket = createSocket()
        if type(data.events.death) == "function" then
            newSocket.events.death = function() pcall(data.events.death) end
        end
        if type(data.events.message) == "function" then
            newSocket.events.message = function() pcall(data.events.message) end
        end
        if type(data.events.asked) == "function" then
            newSocket.events.asked = function() pcall(data.events.asked) end
        end
        if type(data.events.invalidHeader) == "function" then
            newSocket.events.invalidHeader = function() pcall(data.events.invalidHeader) end
        end
        sockets[newId] = newSocket
    elseif command == "deleteSocket" then
        removeSocket(data.id)
    elseif command == "exit" then
        for id in pairs(sockets) do
            removeSocket(id)
        end
        return nil
    elseif command == "connect" then
        
