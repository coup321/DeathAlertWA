function (allstates, ...)
    local eventHandler = aura_env.eventHandler
    local historySize = 4
    local activePlayerDied = eventHandler:process(historySize, ...)
    if activePlayerDied == true then
        local newStates = eventHandler:death(...)

        local i = 1
        for _, newState in pairs(newStates) do
            allstates[i] = newState
            i = i + 1
        end

        return true
    end
end