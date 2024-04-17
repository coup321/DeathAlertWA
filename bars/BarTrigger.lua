function (allstates, ...)
    local eventHandler = aura_env.eventHandler
    local historySize = 4
    local activePlayerDied = eventHandler:process(historySize, ...)
    if activePlayerDied == true then
        local newStates = eventHandler:death(...)

        for i, newState in pairs(newStates) do
            allstates[i] = newState
        end

        return true
    end
end