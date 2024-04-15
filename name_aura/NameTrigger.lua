function(allstates, ...)
    local event, name, sortIndex = ...
    if event == "DEATHLOG_WA" then
        allstates[name] = {
            show = true,
            changed = true,
            autoHide = true,
            duration = 5,
            expirationTime = GetTime() + 5,
            playerName = name,
            sortIndex = sortIndex
        }
        return true
    end
    
end