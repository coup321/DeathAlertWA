function(newPositions, activeRegions)
    -- get config from Bars aura
    local config
    local width
    for i, env in pairs(aura_env.child_envs) do
        if env.config.numberOfDeathsToShow ~= nil then
            config = env.config
            barWidth = env.region.width
        end
    end

    -- calculate rows per player death
    local isNameShown = config.displaySimplePlayerName and 1 or 0
    local isMdiStringShown = config.displayDeathText and 1 or 0
    local isBarsShown = config.displayBars and 1 or 0
    local barsPerDeath = config.historySize
    local addRowBetweenBars = config.addRowBetweenBars and 1 or 0
    local rowsPerDeath = (barsPerDeath+addRowBetweenBars)*isBarsShown + isMdiStringShown + isNameShown
    local maxNumberOfRows = rowsPerDeath * config.numberOfDeathsToShow
    local padding = config.barPadding
    
    local y = 0
    for i = 1, #activeRegions do
        local regionData = activeRegions[i]
        local j = #activeRegions > maxNumberOfRows and i - (#activeRegions - maxNumberOfRows) or i
        local width = regionData.dimensions.width / 2
        local height = regionData.dimensions.height + padding

        if j == 1 then
            y = 0
        end

        local show = i > #activeRegions - maxNumberOfRows
        local x = width - barWidth / 2
        y = y - height + padding

        newPositions[i] = {x, y, show}
    end
end