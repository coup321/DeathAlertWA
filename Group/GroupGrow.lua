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

    -- define an MDI index, since it'll need to be used twice 
    -- one time for each MDI string part (1 and 2)
    local mdiIndex = nil
    for i, regionData in ipairs(activeRegions) do

        if i > maxNumberOfRows then -- there are more active auras than allowed rows
            break
        end

        local width = regionData.dimensions.width / 2
        local id = regionData.id

        if id == "MDI2" then
            width = width + mdiP1Width
        end

        if mdiIndex == nil and (id == "MDI2" or id == "MDI") then
            mdiIndex = i + 1
        end

        if id == "MDI" or id == "MDI2" then
            newPositions[i] = {width, -1*mdiIndex*25, true}
        else
            newPositions[i] = {width, -1*i*25, true}
        end
    end
end