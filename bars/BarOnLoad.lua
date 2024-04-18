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

    local _, _, iconFileId = GetSpellInfo(260421)
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
    local _, _, iconFileId = GetSpellInfo(spellId)
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


    local _, time, _, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _, amount, overkill, damageType = ...

    local _, _, iconFileId = GetSpellInfo(294480)
    return DamageEvent:new(
        "ENVIRONMENTAL_DAMAGE",
        time,
        sourceName,
        "Environment",
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
    local typeColor = self.damageType and damageTypes[self.damageType]['color'] or nil
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
        return string.format("%.1fk", self.overkill/1000)
    end

    return "??"
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

    else -- there are multiple spell damage types
        local damageEvent = DamageEvent:fromSpell(health, ...)
        table.insert(self.history, damageEvent)
    end

    if eventType == "ENVIRONMENTAL_DAMAGE" then
        local damageEvent = DamageEvent:fromEnvironmental(health, ...)
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
    self.health = UnitHealth(self.unitId, true) / UnitHealthMax(self.unitId)
end

local Config = {}
Config.__index = Config

function Config:new(config, deathCount)
    config = config or aura_env.config  -- Fallback to aura_env.config if no config is provided
    local instance = setmetatable({}, Config)
    instance.visibilityDuration = config.visibilityDuration
    instance.displaySimplePlayerName = config.displaySimplePlayerName
    instance.displayDeathText = config.displayDeathText
    instance.displayBars = config.displayBars
    instance.includeOverkillOnDeathText = config.includeOverkillOnDeathText
    instance.includeOverkillOnBars = config.includeOverkillOnBars
    instance.numberofDeathstoShow = config.numberofDeathstoShow
    instance.deathCount = deathCount
    instance.barsPerDeath = 4
    return instance
end

function Config:sortIndex()
    local isNameShown = self.displaySimplePlayerName and 1 or 0
    local isMdiStringShown = self.displayDeathText and 1 or 0
    local isBarsShown = self.displayBars and 1 or 0
    local barsPerDeath = 4
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
    local barsPerDeath = 4
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
    local barsPerDeath = 4
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
    local displaySimplePlayerName = self.config.displaySimplePlayerName
    local displayBars = self.config.displayBars
    local history = player:getDamageHistory():getLastDamage()

    if displayDeathText then
        self:runMdi(player, visibilityDuration)
        self:advanceSortIndex()
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
            sortIndex = self.sortIndex
        }
        self:advanceSortIndex()
    end 

    if #history < self.config.barsPerDeath then
        -- just emit a few empty strings to fill blank spaces
        local n = self.config.barsPerDeath - #history
        self:sendBlanks(n, visibilityDuration)
    end

    self:advanceSortIndex()
    return newStates
end

function StateEmitter:sendBlanks(n, visibilityDuration)
    for i = 1, n do
        WeakAuras.ScanEvents("DEATHLOG_WA", "", self.sortIndex, visibilityDuration)
        self:advanceSortIndex()
    end
end

function StateEmitter:runMdi(player, visibilityDuration)

    local mdiHistory = player:getDamageHistory():getLastDamage()
    local damageEvent = mdiHistory[#mdiHistory]
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
    WeakAuras.ScanEvents("DEATHLOG_WA_MDITEXT", unitId, abilityName, amount, sourceName, icon, self.sortIndex, overkill, visibilityDuration, damageColorString)
    self:advanceSortIndex()
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

function Group:update(historySize)
    self.players = {}
    for unitId in WA_IterateGroupMembers() do
        local name = UnitName(unitId)
        print("added: " .. name)
        self:addPlayer(unitId, historySize)
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
        SPELL_PERIODIC_DAMAGE = true,
        SPELL_BUILDING_DAMAGE = true
    }

    if self.group == nil then
        self.group = Group:update(historySize)
    end
    
    if subEvent == "GROUP_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
        print("Updating group, subevent and event are: ", subEvent, event)
        self:roster(historySize)
        
    elseif  event == "UNIT_HEALTH" then
        self:health(...)

    elseif  subEvent == "UNIT_DIED" then
        return self:activePlayerDied(...)


    elseif damageEvents[subEvent] then
        self:damage(...)
    end
end

function EventHandler:activePlayerDied(...)
    local destGUID = select(9, ...)
    local player = self.group:getPlayer(destGUID)
    if player then
        return true
    end
    return false
end

function EventHandler:roster(historySize)
    self.group = Group:update(historySize)
end

function EventHandler:damage(...)
        local destGUID = select(9, ...)
        local player = self.group:getPlayer(destGUID)
        if player then
            player:getDamageHistory():addDamage(player.health, ...)
        end
end

function EventHandler:health(...)
    local _, unitId = ...
    local unitGUID = UnitGUID(unitId)
    local player = self.group:getPlayer(unitGUID)
    if player then
        player:updateHealth()
    end
end

function EventHandler:death(...)
    local destGUID = select(9, ...)
    local player = self.group:getPlayer(destGUID)
    
    if player then
        self.playerDied = true
        local eventTime = select(2, ...)
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
