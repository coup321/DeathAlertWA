function(allstates, ...)
    local event, name, allstatesIndex = ...
    if event == "DEATHLOG_WA" then
        allstates[allstatesIndex] = {
            show = true,
            changed = true,
            autoHide = true,
            duration = 5,
            expirationTime = GetTime() + 5,
            playerName = name
        }
        return true
    end
    
end