function (allstates, ...)
    local group = aura_env.group
    local stateEmitter = aura_env.stateEmitter
    local event, eventTime, subEvent, _, _, sourceName, _, _, destGUID, destName, _, _, amount, overkill = ...

    local damageEvents = {
        SPELL_DAMAGE = true,
        SWING_DAMAGE = true,
        RANGE_DAMAGE = true,
        SPELL_PERIODIC_DAMAGE = true,
        SPELL_BUILDING_DAMAGE = true
    }

    if subEvent == "GROUP_ROSTER_UPDATE" then
        group:update()

    elseif damageEvents[subEvent] then
        local player = group:getPlayer(destGUID)
        if player then
            player:getDamageHistory():addDamage(player.health, ...)
        end

    elseif subEvent == "UNIT_DIED" then
        local player = group:getPlayer(destGUID)
        if player then
            local newEvents = stateEmitter:run(player, eventTime)
            for key, newEvent in pairs(newEvents) do
                allstates[key] = newEvent
            end
            player:getDamageHistory():resetHistory()
            return true
        end
    end
end