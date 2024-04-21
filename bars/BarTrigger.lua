function (allstates, ...)
    local eventHandler = aura_env.eventHandler
    local historySize = aura_env.config.historySize
    local event = select(1, ...)
    eventHandler:process(historySize, ...)
    if event == "DEATHLOG_WA_PLAYERDIED" then
        local _, eventTime, guid = ...
        local newStates = eventHandler:death(eventTime, guid)
        for i, newState in pairs(newStates) do
            allstates[i] = newState
        end
        return true
    end
end