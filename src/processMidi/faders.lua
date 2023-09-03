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
            local state = stateUtils.get(fader)
            if state == faderStates.unknown then
                if value >= reasonValue - constants.pickupTolerance and value <= reasonValue + constants.pickupTolerance then
                    stateUtils.set(fader, faderStates.inSync)
                elseif value < reasonValue then
                    stateUtils.set(fader, faderStates.tooLow)
                elseif value > reasonValue then
                    stateUtils.set(fader, faderStates.tooHigh)
                end
            elseif state == faderStates.tooLow then
                if value >= reasonValue then
                    stateUtils.set(fader, faderStates.inSync)
                end
            elseif state == faderStates.tooHigh then
                if value <= reasonValue then
                    stateUtils.set(fader, faderStates.inSync)
                end
            end
            faderStates[fader].sl = value

            if stateUtils.getNext(fader) == faderStates.inSync then
                faderStates[fader].reason = value

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
