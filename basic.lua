local interfaces = {}
function addInterface(side)
    if peripheral.getType(side) == "modem" then
        local prefix = peripheral.call(side, "isWireless") ? "wlan" : "eth"

function genListen(port, address)
    assert(isValidPort(port), "Invalid port")
    assert(isValidAdress(address) or (address == nil), "Invalid address")
    return coroutine.create(function()
        while true do
            local e = {os.pullEventRaw()}
            if e[1] == "modem_message" and type(e[5]) == "table" and e[5].port == port and (e[5].to == address or not address) then
                coroutine.yield(true, e[5].msg, e[5].address)
