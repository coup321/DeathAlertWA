function(allstates, ...)
    local event, unitId, sortIndex, visibilityDuration = ...
    if event == "DEATHLOG_WA" then
        allstates[unitId .. sortIndex] = {
            show = true,
            changed = true,
            autoHide = true,
            duration = visibilityDuration,
            expirationTime = GetTime() + visibilityDuration,
            unitId = unitId,
            sortIndex = sortIndex,
            tag = "Name"
        }
        return true
    end
    
end