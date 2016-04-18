local layer_0 = loadfile("layer_0")

return {
    function connect(modem, port, to, from, key, keytable)
        local timer = os.startTimer(5)
        local transmitTimer = os.startTimer(0.5)
        while true do
            layer_0.transmit(modem, port, "CONNECT", to, from, key)
            local e, timeID, _, _, msg = os.pullEvent()
            if e == "timer" then
                if timeID == timer then
                    layer_0.transmit(modem, port, "CONNECT FAIL", to, from, key)
                    return false, "time-out"
                elseif timeID == transmitTimer then
                    layer_0.transmit(modem, port, "CONNECT", to, from, key)
                end
            elseif e == "modem_message" then
                local msg, signed = layer_0.interpret(from, port, msg, keytable) --Note: "from" is me, the connection is "from" me
                if msg and (signed or (not keytable(msg.to)) then
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
    listen = coroutine.create(function(modem, me, port, key, keytable, blacklist, whitelist, allowUnknown)
        while true do
            local _, _, _, _, msg = os.pullEvent("modem_message")
            local msg, signed = layer_0.interpret(me, port, msg, keytable)
            local ok = false
            if msg and ((not blacklist) or (not blacklist[msg.from])) and ((not whitelist) or whitelist[msg.from]) then
                if not signed then
                    if not keytable[msg.from] then
                        if allowUnknown then
                            layer_0.transmit(modem, port, "OK BUT UNIDENTIFIED", msg.from, me, key)
                            ok = true
                        else
                            layer_0.transmit(modem, port, "UNIDENTIFIED", msg.from, me, key)
                        end
                    else
                        layer_0.transmit(modem, port, "UNSIGNED", msg.from, me, key)
                    end
                end
                if ok then
                    if msg.msg == "HELP" then
                        
                    coroutine.yield(msg, signed)
                end
            end
        end
    end),
    function askKey(modem, me, helper, port, key, keytable)
        
