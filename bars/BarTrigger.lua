function (allstates, ...)
    local eventHandler = aura_env.eventHandler
    local historySize = 4
    local activePlayerDied = eventHandler:process(historySize, ...)
    if activePlayerDied == true then
        local newStates = eventHandler:death("recap", ...)
        WeakAuras.ScanEvents("DEATHLOG_WA", player.name, #allstates)
        for i, newState in ipairs(newStates) do
            -- for sim purposes
            if #allstates == 5 then
                WeakAuras.ScanEvents("DEATHLOG_WA", player.name .. 2, #allstates)
            end
            -- for sim purposes
            i = i + #allstates
            allstates[i] = newState
        end
        return true
    end
end