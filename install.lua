term.clear()
term.setCursorPos(1, 1)

local program = {
    "local old = loadstring(\"",
    "\")\nlocal new
}

local continue = not fs.exists("startup")
if not continue then
    term.write("Prepend data to startup? (y/n): ")
    while true do
        local _, k = os.pullEvent("key")
        if k == keys.y then
            continue = true
            break
        elseif k == keys.n then
            break
        end
    end
end

if not continue then
    term.write("Exiting...")
else
    term.write("Editing startup...")
    local f = fs.open("startup", "r")
    local data = f.readAll():gsub("\\", "\\\\"):gsub("\"", "\\\""):gsub("\n", "\\n")
    f.close()
    f = fs.open("startup", "w")
    f.write("local old = loadstring(\"" .. data .. "\")\nlocal new = \"" .. program .. "\")
