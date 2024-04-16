function(allstates, ...)
    local event, name, sortIndex, visibilityDuration = ...
    if event == "DEATHLOG_WA" then
        allstates[name] = {
            show = true,
            changed = true,
            autoHide = true,
            duration = visibilityDuration,
            expirationTime = GetTime() + visibilityDuration,
            playerName = name,
            sortIndex = sortIndex
        }
        return true
    end
    
end