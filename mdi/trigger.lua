function (allstates, ...)
    local eventHandler = aura_env.eventHandler
    local historySize = 1
    local activePlayerDied = eventHandler:process(historySize, ...)
    if activePlayerDied == true then
        local newStates = eventHandler:death("mdi", ...)
        for key, newState in pairs(newStates) do
            allstates[key] = newState
        end
        return true
    end
end