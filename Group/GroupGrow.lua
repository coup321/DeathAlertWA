function(newPositions, activeRegions)
    -- get config from Bars aura
    local config
    local height
    for i, env in pairs(aura_env.child_envs) do
        if env.id == "Bars" then
            config = env.config
            height = env.region.height
        end
    end

    -- calculate rows per player death
    local isNameShown = config.displaySimplePlayerName and 1 or 0
    local isMdiStringShown = config.displayDeathText and 1 or 0
    local isBarsShown = config.displayBars and 1 or 0
    local barsPerDeath = config.historySize
    local rowsPerDeath = barsPerDeath*isBarsShown + 2*isMdiStringShown + isNameShown
    -- max number of rows must be calculated based on 
        -- if name is shown (1 row)
        -- if MDI string is shown (2 rows)
        -- how many bars are allowed (n rows) - 4 is default
    local maxNumberOfRows = rowsPerDeath * config.numberOfDeathsToShow
    local barPadding = config.barPadding
    height = height + barPadding

    local mdiIndex = nil
    local mdiP1Width = 0
    local offset = -1
    local isReset = false
    for i = 1, #activeRegions do
        local regionData = activeRegions[i]
        local j = #activeRegions > maxNumberOfRows and i - (#activeRegions - maxNumberOfRows) or i
        j = j + math.floor((j-1)/rowsPerDeath)
        local width = regionData.dimensions.width / 2
        local id = regionData.id

        if id == "MDI" then
            mdiP1Width = regionData.dimensions.width
        end

        if id == "MDI2" then
            width = width + mdiP1Width
        end

        local show = i > #activeRegions - maxNumberOfRows

        -- reset the offset when you actually start showing rows
        if i > #activeRegions - maxNumberOfRows and not isReset then
            offset = -1
            isReset = true
        end
        -- if it's the second MDI item, then set the index to be j - 1
        -- if it's not the first MDI item, then it also needs offset added to it
        -- iterate offset down one
        if id == "MDI2" then
            mdiIndex = j - 1 + offset
            offset = offset - 1
            newPositions[i] = {width, -1*mdiIndex*height, show}
        else
            j = j + offset
            newPositions[i] = {width, -1*j*height, show}
        end
    end
end