function (allstates, ...)
    local eventHandler = aura_env.eventHandler
    local historySize = 4
    local activePlayerDied = eventHandler:process(historySize, ...)
    if activePlayerDied == true then
        local newStates, playerName = eventHandler:death("recap", ...)

        local lenNewStates = 0
        for _ in pairs(newStates) do
            lenNewStates = lenNewStates + 1
        end
        print("len of new states before loop: ", lenNewStates)

        local lenAllStates = 0
        for _ in pairs(allstates) do
            lenAllStates = lenAllStates + 1
        end

        print("len all states before loop: ", lenAllStates)


        local i = 1
        for _, newState in pairs(newStates) do
            allstates[i] = newState
            i = i + 1
        end

        lenAllStates = 0
        for _ in pairs(allstates) do
            lenAllStates = lenAllStates + 1
        end
        print("Length of allstates is ", lenAllStates)
        return true
    end
end