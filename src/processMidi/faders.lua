local faderStates = require("lib.faderStates")
local items = require("lib.mixerItems")
local constants = require("lib.constants")
local debugUtils = require("lib.debugUtils")

return function(event)
    local processed = false

    for i = 1, 8 do
        local fader = "fader" .. i
        local ret = remote.match_midi(items[fader].midiMatcher, event)
        if ret then
            local value = ret.x
            local reasonValue = faderStates[fader].reason
            local state = faderStates[fader].state
            local inSync = state == constants.inSync
            if inSync == false then
                debugUtils.log("Fader is out of sync")
                if value == reasonValue then
                    debugUtils.log("SL fader now has same value as Reason, now in sync")
                    inSync = true
                end
                if value > reasonValue and state == constants.tooLow then
                    debugUtils.log("SL fader was too low, now has value higher than Reason, now in sync")
                    inSync = true
                end
                if value < reasonValue and state == constants.tooHigh then
                    debugUtils.log("SL fader was too high, now has value lower than Reason, now in sync")
                    inSync = true
                end
            else
                debugUtils.log("SL fader already in sync with Reason")
            end

            if inSync then
                faderStates[fader].state = constants.inSync
                faderStates[fader].sl = value
                faderStates[fader].reason = value
                debugUtils.log("Sending fader value " .. tostring(value) .. " to Reason")

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
