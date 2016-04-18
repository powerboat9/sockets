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
                local msg, signed = layer_0.interpret(from, port, msg, keytable)
                if msg and (signed or (not keytable(msg.to)) then
                    if msg.msg == "ACCEPT CONNECT" then
                        return true
                    elseif msg.msg == "DENY ATTEMPT" then
                        return false, "denied"
                    end
                end
            end
        end
    end,
    listen = coroutine.create(function(me, port, whitelist, blacklist)
        )
            
                
        
