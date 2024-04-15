-- DamageEvent
local DamageEvent = {}
DamageEvent.__index = DamageEvent

function DamageEvent:new(type, time, sourceName, abilityName, amount, overkill, icon, health)
    local instance = setmetatable({}, DamageEvent)
    instance.type = type
    instance.time = time
    instance.health = health
    instance.sourceName = sourceName
    instance.abilityName = abilityName
    instance.amount = amount
    instance.overkill = overkill
    instance.icon = icon
    return instance
end


function DamageEvent:fromSwing(health, ...)


    local _, time, _, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _, amount, overkill = ...

    local _, _, iconFileId = GetSpellInfo(260421)
    return DamageEvent:new(
        "SWING_DAMAGE",
        time,
        sourceName,
        "Melee",
        amount,
        overkill,
        iconFileId,
        health
    )
end

function DamageEvent:fromSpell(health, ...)
    local _, time, subEvent, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _, spellId, spellName, spellSchool, amount, overkill = ...
    local _, _, iconFileId = GetSpellInfo(spellId)
    return DamageEvent:new(
        "SPELL_DAMAGE",
        time,
        sourceName,
        spellName,
        amount,
        overkill,
        iconFileId,
        health
    )
end

function DamageEvent:fromEnvironmental(health, ...)


    local _, time, _, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _, amount, overkill = ...

    local _, _, iconFileId = GetSpellInfo(294480)
    return DamageEvent:new(
        "ENVIRONMENTAL_DAMAGE",
        time,
        sourceName,
        "Environment",
        amount,
        overkill,
        iconFileId,
        health
    )
end

function DamageEvent:getTime()
    return self.time
end

function DamageEvent:getAmount()
    return self.amount
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


function Player:getDamageHistory()
    return self.damageHistory
end

function Player:getHealthPercent()
    return string.format("%.0f%%", 100 * self.currentHealth / self.maxHealth)
end


function Player:updateHealth()
    self.health = UnitHealth(self.unitId, true) / UnitHealthMax(self.unitId)
end

-- StateEmitter
local StateEmitter = {}
StateEmitter.__index = StateEmitter

function StateEmitter:new()
    local instance = setmetatable({},StateEmitter)
    return instance
end

function StateEmitter:runRecap(player, emitTime)
    local history = player:getDamageHistory():getLastDamage()
    local newEvents = {}
    for i, damageEvent in ipairs(history) do
        newEvents[player.name .. i] = {
            show = true,
            changed = true,
            autoHide = true,
            progressType = "static",
            value = damageEvent.health,
            total = 1,
            duration = 5,
            expirationTime = GetTime() + 5,
            amount = self:formatAmount(damageEvent.amount), -- returns a formatted string
            abilityName = damageEvent.abilityName,
            sourceName = damageEvent.sourceName,
            timeDelta = damageEvent:getTimeDelta(emitTime),
            icon = damageEvent:getIcon(),
        }
    end
    -- for simulation
    for i, damageEvent in ipairs(history) do
        newEvents[player.name .. (i + 100)] = {
            show = true,
            changed = true,
            autoHide = true,
            progressType = "static",
            value = damageEvent.health,
            total = 1,
            duration = 5,
            expirationTime = GetTime() + 5,
            amount = self:formatAmount(damageEvent.amount), -- returns a formatted string
            abilityName = damageEvent.abilityName,
            sourceName = damageEvent.sourceName,
            timeDelta = damageEvent:getTimeDelta(emitTime),
            icon = damageEvent:getIcon(),
        }
    end

    -- end for simulation 
    return newEvents
end


function StateEmitter:runMdi(player, emitTime)
    local history = player:getDamageHistory():getLastDamage()
    local newEvents = {}
    for i, damageEvent in ipairs(history) do
        newEvents[player.name .. i] = {
            show = true,
            changed = true,
            autoHide = true,
            duration = 5,
            expirationTime = GetTime() + 5,
            amount = self:formatAmount(damageEvent.amount), -- returns a formatted string
            abilityName = damageEvent.abilityName,
            icon = damageEvent:getIcon(),
            unitId = player.unitId,
            sourceName = damageEvent.sourceName
        }
    end
    return newEvents
end

function StateEmitter:formatAmount(amount)
    return string.format("%iK", amount/1000)
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
    
    if subEvent == "GROUP_ROSTER_UPDATE" then
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

function EventHandler:death(runType, ...)
    local destGUID = select(9, ...)
    local player = self.group:getPlayer(destGUID)
    
    if player then
        self.playerDied = true
        local destGUID = select(9, ...)
        local eventTime = select(2, ...)
        local stateEmitter = StateEmitter:new()
        if runType == "mdi" then
            self.newStates = stateEmitter:runMdi(player, eventTime)
        elseif runType == "recap" then
            WeakAuras.ScanEvents("DEATHLOG_WA", player.name)
            self.newStates = stateEmitter:runRecap(player, eventTime)
            -- for simulation of duplicates
            WeakAuras.ScanEvents("DEATHLOG_WA", player.name .. 2)
            -- simulation
        end
        player:getDamageHistory():resetHistory()
        return self.newStates
    end
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
