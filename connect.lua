local layer_0 = loadfile("layer_0")

return {
    function connect(modem, port, to, from, key, keytable)
        layer_0.transmit(modem, port, "CONNECT", to, from, key)
        local broadcast = coroutine.create(function() layer_0.transmit(modem, port, "CONNECT", to, from, key); coroutine.yield() end)
        local timer = os.startTimer(5)
        local listen = coroutine.create(function()
            local returnValue = false
            while true do
                local e, timeID, _, _, msg = os.pullEvent()
                if (e == "timer") and (timeID == timer) then
                    layer_0.transmit(modem, port, "CONNECT FAIL", to, from, key)
                    break
                elseif e == "modem_message" then
                    local msg, signed = layer_0.interpret(port, msg, keytable)
                    if msg and (signed or (not keytable(msg.to)) then
                        if msg.msg == "ACCEPT CONNECT" then
                            returnValue = 
                        elseif msg.msg == "DENY ATTEMPT" then
                            coroutine.yield(true)
                        else
                            continue
                        end
                        break
                    end
                end
            end
        end
                
        
