local faderStates = require("lib.faderStates")
local items = require("lib.mixerItems")
local constants = require("lib.constants")
local debugUtils = require("lib.debugUtils")
local stateUtils = require("lib.stateUtils")

return function(event)
    local processed = false

    for i = 1, 8 do
        local fader = "fader" .. i
        local ret = remote.match_midi(items[fader].midiMatcher, event)
        if ret then
            local value = ret.x
            local reasonValue = faderStates[fader].reason
            -- local state = faderStates[fader].state
            local state = stateUtils.get(fader)
            if state == faderStates.unknown then
                if value >= reasonValue - constants.pickupTolerance and value <= reasonValue + constants.pickupTolerance then
                    debugUtils.log("Inital " .. fader .. " value " .. tostring(value) .. " received, state is 'in sync'")
                    -- faderStates[fader].state = faderStates.inSync
                    stateUtils.set(fader, faderStates.inSync)
                elseif value < reasonValue then
                    debugUtils.log("Initial " .. fader .. " value " .. tostring(value) ..
                                       " received, state is 'too low'")
                    -- faderStates[fader].state = faderStates.tooLow
                    stateUtils.set(fader, faderStates.tooLow)
                elseif value > reasonValue then
                    debugUtils.log("Initial " .. fader .. " value " .. tostring(value) ..
                                       " received, state is 'too high'")
                    -- faderStates[fader].state = faderStates.tooHigh
                    stateUtils.set(fader, faderStates.tooHigh)
                end
            elseif state == faderStates.tooLow then
                if value >= reasonValue then
                    debugUtils.log("Value " .. tostring(value) .. " of " .. fader .. " received, state is now 'in sync'")
                    -- faderStates[fader].state = faderStates.inSync
                    stateUtils.set(fader, faderStates.inSync)
                else
                    debugUtils.log("Value " .. tostring(value) .. " of " .. fader ..
                                       " received, state is still 'too low'")
                end
            elseif state == faderStates.tooHigh then
                if value <= reasonValue then
                    debugUtils.log("Value " .. tostring(value) .. " of " .. fader .. " received, state is now 'in sync'")
                    -- faderStates[fader].state = faderStates.inSync
                    stateUtils.set(fader, faderStates.inSync)
                else
                    debugUtils.log("Value " .. tostring(value) .. " of " .. fader ..
                                       " received, state is still 'too high'")
                end
            end
            faderStates[fader].sl = value

            -- if faderStates[fader].state == faderStates.inSync then
            if stateUtils.getNext(fader) == faderStates.inSync then
                faderStates[fader].reason = value
                debugUtils.log("Sending " .. fader .. " value " .. tostring(value) .. " to Reason")

                -- CODEC => REASON
                remote.handle_input({
                    item = items[fader].index,
                    value = value,
                    time_stamp = event.time_stamp
                })
                processed = true
            end
        end
    end

    return processed
end
