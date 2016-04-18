local layer_0 = loadfile("layer_0")

local api = {
    function connect(self, port, to, from, key)
        local timer = os.startTimer(5)
        local transmitTimer = os.startTimer(0.5)
        while true do
            layer_0.transmit(modem, port, "CONNECT", to, from, key)
            local e, timeID, _, _, msg = os.pullEvent()
            if e == "timer" then
                if timeID == timer then
                    layer_0.transmit(self.modem, port, "CONNECT FAIL", to, from, key)
                    return false, "time-out"
                elseif timeID == transmitTimer then
                    layer_0.transmit(self.modem, port, "CONNECT", to, from, key)
                end
            elseif e == "modem_message" then
                local msg, signed = layer_0.interpret(from, port, msg, self.keytable) --Note: "from" is me, the connection is "from" me
                if msg and (signed or (not self.keytable(msg.to)) then
                    if (msg.msg == "ACCEPT CONNECT") or (msg.msg == "OK BUT UNIDENTIFIED") then
                        return true
                    elseif msg.msg == "UNIDENTIFIED" then
                        return false, "unknown"
                    elseif msg.msg == "UNSIGNED" then
                        return false, "impositor"
                    elseif msg.msg == "DENY ATTEMPT" then
                        return false, "denied"
                    end
                end
            end
        end
    end,
    function getListener(self, me, port, key, blacklist, whitelist, allowUnknown)
        return coroutine.create(function()
            while true do
                local _, _, _, _, msg = os.pullEvent("modem_message")
                local msg, signed = layer_0.interpret(me, port, msg, self.keytable)
                local ok = false
                if msg and ((not blacklist) or (not blacklist[msg.from])) and ((not whitelist) or whitelist[msg.from]) then
                    if not signed then
                        if not self.keytable[msg.from] then
                            if allowUnknown then
                                layer_0.transmit(self.modem, port, "OK BUT UNIDENTIFIED", msg.from, me, key)
                                ok = true
                            else
                                layer_0.transmit(self.modem, port, "UNIDENTIFIED", msg.from, me, key)
                            end
                        else
                            layer_0.transmit(self.modem, port, "UNSIGNED", msg.from, me, key)
                        end
                    end
                    if ok then
                        if (msg.msg == "HELP") and (port = 200) then
                            layer_0.transmit(self.modem, port, "HELPING WITH: " .. textutils.serialize(keytable), msg.from, me, key)
                        else
                            coroutine.yield(msg, signed)
                        end
                    end
                end
            end
        end)
    end,
    function askKey(self, me, helper, key)
        layer_0.transmit(self.modem, 200, "HELP", helper, me, key)
        local listener = self:getListener(me, 200, key)
        while true do
            if
        
