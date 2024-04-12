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
    end

    if eventType == "SPELL_DAMAGE" then
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

function Player:new(unitId)
    local instance = setmetatable({}, Player)
    instance.damageHistory = DamageHistory:new(3)
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

function StateEmitter:run(player, emitTime)
    local history = player:getDamageHistory():getLastDamage()
    local newEvents = {}
    for i, damageEvent in ipairs(history) do
        newEvents[i] = {
            show = true,
            changed = true,
            autoHide = true,
            progressType = "static",
            value = damageEvent.health,
            total = 1,
            duration = 5,
            expirationTime = GetTime() + 5,
            amount = self.ammount(player), -- returns a formatted string
            abilityName = damageEvent.abilityName,
            timeDelta = damageEvent:getTimeDelta(emitTime),
            icon = damageEvent:getIcon(),
        }
    end
    return newEvents
end

function StateEmitter:amount(player)
    return string.format("%ik", player.amount/1000)
end



-- Group
local Group = {}
Group.__index = Group

function Group:new()
    local instance = setmetatable({}, Group)
    instance.players = {}
    return instance
end


function Group:addPlayer(unitId)
    local playerGUID = UnitGUID(unitId)
    if not self.players[playerGUID] then
        self.players[playerGUID] = Player:new(unitId)
    end
end

function Group:update()
    self.players = {}
    for unitId in WA_IterateGroupMembers() do
        local name = UnitName(unitId)
        print("added: " .. name)
        self:addPlayer(unitId)
    end
end

function Group:getPlayer(GUID)
    return self.players[GUID]
end


-- Setup WA Environment

aura_env.round = function (num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    num = num or 0
    return math.floor(num * mult + 0.5) / mult
end

aura_env.group = Group:new()
aura_env.group:update()
aura_env.stateEmitter = StateEmitter:new()
