local GetSpellInfo = C_Spell and C_Spell.GetSpellInfo or GetSpellInfo

-- DamageEvent
local DamageEvent = {}
DamageEvent.__index = DamageEvent

function DamageEvent:new(type, time, sourceName, abilityName, amount, damageType, overkill, icon, health)
    local instance = setmetatable({}, DamageEvent)
    instance.type = type
    instance.time = time
    instance.health = health
    instance.sourceName = sourceName
    instance.abilityName = abilityName
    instance.amount = amount
    instance.damageType = damageType
    instance.overkill = overkill
    instance.icon = icon
    return instance
end


function DamageEvent:fromSwing(health, ...)
    local _, time, _, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _, amount, overkill, damageType = ...

    local iconFileId = GetSpellInfo(260421)["iconID"]
    return DamageEvent:new(
        "SWING_DAMAGE",
        time,
        sourceName,
        "Melee",
        amount,
        damageType,
        overkill,
        iconFileId,
        health
    )
end

function DamageEvent:fromSpell(health, ...)
    local _, time, subEvent, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _, spellId, spellName, damageType, amount, overkill  = ...
    
    local iconFileId = GetSpellInfo(spellId)["iconID"]
    return DamageEvent:new(
        "SPELL_DAMAGE",
        time,
        sourceName,
        spellName,
        amount,
        damageType,
        overkill,
        iconFileId,
        health
    )
end


function DamageEvent:fromEnvironmental(health, ...)


    local _, time, subEvent, hideCaster, sourceGUID, sourceName, _, _, destGUID, destName, _, _, spellName, amount, overkill, damageType = ...

    local iconFileId = GetSpellInfo(294480)["iconID"]
    return DamageEvent:new(
        "ENVIRONMENTAL_DAMAGE",
        time,
        "Environment",
        spellName,
        amount,
        damageType,
        overkill,
        iconFileId,
        health
    )
end

function DamageEvent:damageColorString()
    local damageTypes = {
        [1] = { name = "Physical", color = "FFFf00" },
        [2] = { name = "Holy", color = "FFE680" },
        [4] = { name = "Fire", color = "FF8000" },
        [8] = { name = "Nature", color = "4DFF4D" },
        [16] = { name = "Frost", color = "80FFFF" },
        [32] = { name = "Shadow", color = "8080FF" },
        [64] = { name = "Arcane", color = "FF80FF" },
    }
    local typeColor = damageTypes[self.damageType] and damageTypes[self.damageType]['color'] or nil
    return typeColor and typeColor or "FFFf00"
end

function DamageEvent:getTime()
    return self.time
end

function DamageEvent:getAmountWithOverkill()
    if self.overkill > 0 then
        local amountString = string.format("%.1fk", self.amount/1000)
        local coloredOverkill = "|cFF757575" .. "(" ..self:getOverkill() .. ")|r"
 
        return amountString .. " " .. coloredOverkill
    end
    return string.format("%.1fk", self.amount/1000)
end

function DamageEvent:getAmount()
    return string.format("%.1fk", self.amount/1000)
end

function DamageEvent:getOverkill()
    if self.overkill > 0 then 
        return " (" .. string.format("%.1fk", self.overkill/1000).." overkill)"
    end

    return " (?? overkill)"
end

function DamageEvent:getIcon()
    return self.icon
end

function DamageEvent:getTimeDelta(deathTime)
    local diff = (deathTime - self.time)
    return tostring(self:round(diff, 1)) .. "s"
end

function DamageEvent:round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function DamageEvent:sourceNameWithoutServer()
    if not self.sourceName then
        return "Environment"
    end
    local name = self.sourceName:match("^(.-)-")
    if not name then
        name = self.sourceName
    end
    return name
end



-- DamageHistory
local DamageHistory = {}
DamageHistory.__index = DamageHistory

function DamageHistory:new(size)
    local instance = setmetatable({}, DamageHistory)
    instance.size = size
    instance.history = {}
    return instance
end

function DamageHistory:addDamage(health, ...)
    local eventType = select(3, ...)

    if #self.history >= self.size then
        table.remove(self.history, 1)
    end

    if eventType == "SWING_DAMAGE" then
        local damageEvent = DamageEvent:fromSwing(health, ...)
        table.insert(self.history, damageEvent)
    elseif eventType == "ENVIRONMENTAL_DAMAGE" then
        local damageEvent = DamageEvent:fromEnvironmental(health, ...)
        table.insert(self.history, damageEvent)
    else -- there are multiple spell damage types
        local damageEvent = DamageEvent:fromSpell(health, ...)
        table.insert(self.history, damageEvent)
    end

end

function DamageHistory:getLastDamage()
    return self.history
end

function DamageHistory:resetHistory()
    self.history = {}
end

-- Player
local Player = {}
Player.__index = Player

function Player:new(unitId, historySize)
    local instance = setmetatable({}, Player)
    instance.damageHistory = DamageHistory:new(historySize)
    instance.health = UnitHealth(unitId, false) / UnitHealthMax(unitId)
    instance.name = UnitName(unitId)
    instance.guid = UnitGUID(unitId)
    instance.unitId = unitId
    return instance
end

function Player:nameWithoutServer()
    local name = self.name:match("^(.-)-")
    return name
end

function Player:getDamageHistory()
    return self.damageHistory
end

function Player:getHealthPercent()
    return string.format("%.0f%%", 100 * self.currentHealth / self.maxHealth)
end


function Player:updateHealth()
    if aura_env.config.includeHpParsing then
        self.health = UnitHealth(self.unitId, true) / UnitHealthMax(self.unitId)
    else
        self.health = 0
    end
end

function Player:updateUnitId(unitId)
    self.unitId = unitId
end

local Config = {}
Config.__index = Config

function Config:new(config, deathCount)
    config = config or aura_env.config  -- Fallback to aura_env.config if no config is provided
    local instance = setmetatable({}, Config)
    instance.visibilityDuration = config.visibilityDuration
    instance.sortAscending = config.sortAscending
    instance.displaySimplePlayerName = config.displaySimplePlayerName
    instance.displayDeathText = config.displayDeathText
    instance.displayDeathTextSeparately = config.displayDeathTextSeparately
    instance.displayBars = config.displayBars
    instance.includeOverkillOnDeathText = config.includeOverkillOnDeathText
    instance.includeOverkillOnBars = config.includeOverkillOnBars
    instance.numberofDeathstoShow = config.numberofDeathstoShow
    instance.deathCount = deathCount
    instance.addRowBetweenBars = config.addRowBetweenBars and 1 or 0
    instance.barsPerDeath = config.historySize + instance.addRowBetweenBars
    return instance
end

function Config:sortIndex()
    local isNameShown = self.displaySimplePlayerName and 1 or 0
    local isMdiStringShown = self.displayDeathText and 1 or 0
    local isBarsShown = self.displayBars and 1 or 0
    local barsPerDeath = self.barsPerDeath
    local rowsPerDeath = barsPerDeath*isBarsShown + 2*isMdiStringShown + isNameShown
    -- max number of rows must be calculated based on 
        -- if name is shown (1 row)
        -- if MDI string is shown (2 rows)
        -- how many bars are allowed (n rows) - 4 is default
    local newSortIndex = rowsPerDeath * self.deathCount
    return newSortIndex
end

function Config:maxNumberOfRows()
    local isNameShown = self.displaySimplePlayerName and 1 or 0
    local isMdiStringShown = self.displayDeathText and 1 or 0
    local isBarsShown = self.displayBars and 1 or 0
    local barsPerDeath = self.barsPerDeath
    local rowsPerDeath = barsPerDeath*isBarsShown + 2*isMdiStringShown + isNameShown
    -- max number of rows must be calculated based on 
        -- if name is shown (1 row)
        -- if MDI string is shown (2 rows)
        -- how many bars are allowed (n rows) - 4 is default
    local maxNumberOfRows = rowsPerDeath * self.numberOfDeathsToShow
    return maxNumberOfRows
end

function Config:rowsPerDeath()
    local isNameShown = self.displaySimplePlayerName and 1 or 0
    local isMdiStringShown = self.displayDeathText and 1 or 0
    local isBarsShown = self.displayBars and 1 or 0
    local barsPerDeath = self.barsPerDeath
    local rowsPerDeath = barsPerDeath*isBarsShown + 2*isMdiStringShown + isNameShown
    return rowsPerDeath
end

-- StateEmitter
local StateEmitter = {}
StateEmitter.__index = StateEmitter

function StateEmitter:new(deathCount)
    local instance = setmetatable({},StateEmitter)
    instance.sortIndex = nil
    instance.config = Config:new(aura_env.config, deathCount)
    return instance
end

function StateEmitter:run(player, emitTime)
    self.sortIndex = self.config:sortIndex()
    local visibilityDuration = self.config.visibilityDuration
    local displayDeathText = self.config.displayDeathText
    local displayDeathTextSeparately = self.config.displayDeathTextSeparately
    local displaySimplePlayerName = self.config.displaySimplePlayerName
    local displayBars = self.config.displayBars
    local history = player:getDamageHistory():getLastDamage()
    -- handle the infrequent case when a death event is sent, but no damage events have occured
    if #history == 0 then
        return {}
    end

    if displayDeathText then
        self:runMdi(player, visibilityDuration, "WITH_BARS")
        self:advanceSortIndex()
    end


    if displayDeathTextSeparately then
        self:runMdi(player, visibilityDuration, "SEPARATE")
    end

    if displaySimplePlayerName then
        WeakAuras.ScanEvents("DEATHLOG_WA", player.unitId, self.sortIndex, visibilityDuration)
        self:advanceSortIndex()
    end

    if displayBars then
        local newStates =  self:runBars(history, emitTime, visibilityDuration)
        return newStates

    else
        return {}
    end
end

function StateEmitter:runBars(history, emitTime, visibilityDuration)
    local sortAscending = self.config.sortAscending
    if sortAscending then
        local reversedHistory = {}
        for i = #history, 1, -1 do
            table.insert(reversedHistory, history[i])
        end
        history = reversedHistory
    end
    local newStates = {}
    for i, damageEvent in ipairs(history) do

        local amount
        if self.config.includeOverkillOnBars then
            amount = damageEvent:getAmountWithOverkill()
        else
            amount = damageEvent:getAmount()
        end

        newStates[self.sortIndex] = {
            show = true,
            changed = true,
            autoHide = true,
            progressType = "static",
            value = damageEvent.health,
            total = 1,
            duration = visibilityDuration,
            expirationTime = GetTime() + visibilityDuration,
            amount = amount,
            abilityName = damageEvent.abilityName,
            sourceName = damageEvent:sourceNameWithoutServer(),
            timeDelta = damageEvent:getTimeDelta(emitTime),
            icon = damageEvent:getIcon(),
            sortIndex = self.sortIndex,
            tag = "Bars"
        }
        self:advanceSortIndex()
    end 

    if #history < self.config.barsPerDeath then
        -- just emit a few empty strings to fill blank spaces
        local n = self.config.barsPerDeath - #history
        self:sendBlanks(n, visibilityDuration)
    end
    -- send one blank for every set of bars so that there is space after them
    self:advanceSortIndex()
    return newStates
end

function StateEmitter:sendBlanks(n, visibilityDuration)
    for i = 1, n do
        WeakAuras.ScanEvents("DEATHLOG_WA", "", self.sortIndex, visibilityDuration)
        self:advanceSortIndex()
    end
end

function StateEmitter:runMdi(player, visibilityDuration, whichMdi)

    local history = player:getDamageHistory():getLastDamage()
    local damageEvent = history[#history]
    local overkill
    if self.config.includeOverkillOnDeathText then
        overkill = damageEvent:getOverkill()
    else
        overkill = ""
    end

    local unitId = player.unitId
    local abilityName = damageEvent.abilityName
    local amount = damageEvent:getAmount()
    local sourceName = damageEvent:sourceNameWithoutServer()
    local icon = damageEvent:getIcon()
    local damageColorString = damageEvent:damageColorString()
    WeakAuras.ScanEvents("DEATHLOG_WA_MDITEXT_"..whichMdi, unitId, abilityName, amount, sourceName, icon, self.sortIndex, overkill, visibilityDuration, damageColorString, player.name)
end

function StateEmitter:advanceSortIndex(n)
    n = n and n or 1
    self.sortIndex = self.sortIndex + n
end




-- Group
local Group = {}
Group.__index = Group

function Group:new()
    local instance = setmetatable({}, Group)
    instance.players = {}
    return instance
end


function Group:addPlayer(unitId, historySize)
    local playerGUID = UnitGUID(unitId)
    if not self.players[playerGUID] then
        self.players[playerGUID] = Player:new(unitId, historySize)
    end
end

function Group:removeAbsentPlayers()
    local partyMembers = {}
    for unitId in WA_IterateGroupMembers() do
        partyMembers[UnitGUID(unitId)] = true
    end

    for playerGUID, _ in pairs(self.players) do
        if not partyMembers[playerGUID] then
            self.players[playerGUID] = nil
        end
    end
end

function Group:update(historySize)
    if not self.players then
        self.players = {}
    end
    for unitId in WA_IterateGroupMembers() do
        local playerGUID = UnitGUID(unitId)
        local player = self.players[playerGUID]
        if player then
            player:updateUnitId(unitId)
        else
            self:addPlayer(unitId, historySize)
        end
    end

    return self
end

function Group:getPlayer(GUID)
    return self.players[GUID]
end




-- EventHandler
local EventHandler = {}
EventHandler.__index = EventHandler

function EventHandler:new()
    local instance = setmetatable({}, EventHandler)
    instance.group = nil
    instance.playerDied = false
    instance.newStates = {}
    instance.historySize = nil
    instance.deathCount = 0
    return instance
end

function EventHandler:process(historySize, ...)
    local event, _, subEvent = ...

    local damageEvents = {
        SPELL_DAMAGE = true,
        SWING_DAMAGE = true,
        RANGE_DAMAGE = true,
        ENVIRONMENTAL_DAMAGE = true,
        SPELL_PERIODIC_DAMAGE = true,
        SPELL_BUILDING_DAMAGE = true
    }

    if self.group == nil then
        self.group = Group:update(historySize)
    end
    
    if event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
        self:roster(historySize)
        
    elseif  subEvent == "UNIT_DIED" then
        self:activePlayerDied(...)


    elseif damageEvents[subEvent] then
        self:damage(...)
    end
end

function EventHandler:activePlayerDied(...)
    local destGUID = select(9, ...)
    local player = self.group:getPlayer(destGUID)
    if player and UnitIsFeignDeath(player.unitId) ~= true then
        local eventTime = select(2, ...)
        self:updatePlayerDiedStateTrue(eventTime, destGUID)
    end
end

function EventHandler:updatePlayerDiedStateTrue(eventTime, playerGUID)
    C_Timer.After(0.05, function()
        WeakAuras.ScanEvents("DEATHLOG_WA_PLAYERDIED", eventTime, playerGUID)
    end
    )
end

function EventHandler:roster(historySize)
    self.group = Group:update(historySize)
end

function EventHandler:damage(...)
        local destGUID = select(9, ...)
        local player = self.group:getPlayer(destGUID)
        if player then
            player:updateHealth()
            player:getDamageHistory():addDamage(player.health, ...)
        end
end

function EventHandler:death(eventTime, destGUID)
    local player = self.group:getPlayer(destGUID)
    
    if player then
        if aura_env.playerOnly and player.unitId ~= "player" then
            return {}
        end

        self.playerDied = true
        local stateEmitter = StateEmitter:new(self.deathCount)
        self.newStates = stateEmitter:run(player, eventTime)
        player:getDamageHistory():resetHistory()
        self.deathCount = self.deathCount + 1
        return self.newStates
    end
    return {}
end

function EventHandler:unitDied()
    if self.playerDied == true then
        self.playerDied = false
        return true
    end
    return false
end

function EventHandler:getStates()
    return self.newStates
end


-- Setup WA Environment
local eventHandler = EventHandler:new()
aura_env.eventHandler = eventHandler

aura_env.printEvents =  function(...)
    local args = {...}  -- Put all variable arguments into a table
    for i = 1, select('#', ...) do
        args[i] = '"' .. tostring(args[i]) .. '"'  -- Convert each argument to a string
    end

    local argsString = table.concat(args, " ")  -- Concatenate all elements with a comma and space as separator
    print(argsString)
end