local allowWired = ...

math.randomseed(os.time())
math.random()
math.random()

local modem = assert(peripheral.find("modem", function(name, obj)
    return obj.isWireless() or allowWired
end), "Could Not Find Modem")

local sockets = {}
local socketIDs = {}

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
    KEEPALIVE = {}
}

function newSocket()
    local returnSocket = {}
    returnSocket.id = "NONE"
    returnSocket.events = {
        death = nil, --self, (0 - done, 1 - thisForceClose, 2 - otherForceClose)
        message = nil --self, message
    }
    returnSocket.load = function(self, msg)
        local header = ""
        local data = ""
        local body = ""
        do
            local sep = msg:find(":")
            local sep2 = msg:find(":")
            header = msg:sub(1, sep - 1)
            data = msg:sub(sep + 1, sep2 - 1)
            body = msg:sub(sep2 + 1)
        end
        do
            local dataValues = {}
            for k, v in data:gmatch("([^|]*)|([^|]*)#?") do
                
        if not self.events.message(self, msg) then
            return statusEnum.NONE
        end
        if header = "forceClose" then
            self.events.death(self, 2)
        elseif header = "data" then
            if 
