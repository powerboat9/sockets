local cron = {
    data = {},
    interval = 0.25
}
cron.t = os.startTimer(cron.interval)

function startCron(t, funct)
    if type(t) ~= number or t < 0 or type(funct) ~= "function" then
        error("Could not start cron", 2)
    end
    cron.data[#cron.data + 1] = {0, math.ceil(t / cron.interval), funct}
    return #cron.data
end

function stopCron(v)
    if type(v) == "function" then
        for i = 1, #cron.data do
            if cron.data[i][3] == v then
                cron.data[i] = nil
                return true
            end
        end
        return false
    elseif type(v) == "number" then
        if cron.data[v] then
            cron.data[v] = nil
            return true
        end
        return false
    end
    error("Invalid cron identifier", 2)
end

function updateCron(t)
    if cron.t == t then
        for _, v in ipairs(cron.data) do
            if v[1] == 0 then
                pcall(v[3])
            end
            v[1] = (v[1] + 1) % v[2]
        end
        cron.t = os.startTimer(cron.interval)
    end
end

function changeInterval(i)
    if type(i) ~= "number" or i == math.huge or i < 0 then
        error("Invalid interval", 2)
    end
    i = math.ceil(i * 20) / 20
    i = (i == 0) and 0.05 or i
    local m = i / cron.interval
    cron.interval = i
    os.stopTimer(cron.t)
    cron.t = os.startTimer(i)
    for i = 1, #cron.data do
        local c = cron.data[i]
        c[1], c[2] = c[1] * m, c[2] * m
    end
end