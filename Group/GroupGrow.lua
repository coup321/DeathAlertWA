function(newPositions, activeRegions)
    -- get config from Bars aura
    local config
    for i, env in pairs(aura_env.child_envs) do
        if env.id == "Bars" then
            config = env.config
        end
    end

    -- get width of the first half of the MDI style string
    -- can't guarantee that part 1 will come first, so need to iterate through
    local mdiP1Width = 0
    for _, regionData in pairs(activeRegions) do
        local id = regionData.id
        if id == "MDI" then
            mdiP1Width = regionData.dimensions.width
            break
        end
    end

    -- calculate rows per player death
    local isNameShown = config.displaySimplePlayerName and 1 or 0
    local isMdiStringShown = config.displayDeathText and 1 or 0
    local isBarsShown = config.displayBars and 1 or 0
    local barsPerDeath = 4
    local rowsPerDeath = barsPerDeath*isBarsShown + 2*isMdiStringShown + isNameShown
    -- max number of rows must be calculated based on 
        -- if name is shown (1 row)
        -- if MDI string is shown (2 rows)
        -- how many bars are allowed (n rows) - 4 is default
    local maxNumberOfRows = rowsPerDeath * config.numberOfDeathsToShow

    local mdiIndex = nil
    for i = 1, #activeRegions do 
        local regionData = activeRegions[i]
        local j = #activeRegions > maxNumberOfRows and i - (#activeRegions - maxNumberOfRows) or i
        local width = regionData.dimensions.width / 2
        local id = regionData.id

        if id == "MDI2" then
            width = width + mdiP1Width
        end

        local show = i > #activeRegions - maxNumberOfRows

        if id == "MDI" then
            mdiIndex = j + 1
            newPositions[i] = {width, -1*mdiIndex*25, show}
        else
            newPositions[i] = {width, -1*j*25, show}
        end
    end
end