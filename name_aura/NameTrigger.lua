function(allstates, ...)
    local event, unitId, sortIndex, visibilityDuration = ...
    if event == "DEATHLOG_WA" then
        allstates[unitId] = {
            show = true,
            changed = true,
            autoHide = true,
            duration = visibilityDuration,
            expirationTime = GetTime() + visibilityDuration,
            unitId = unitId,
            sortIndex = sortIndex
        }
        return true
    end
    
end