local stateUtils = require("lib.stateUtils")
local items = require("lib.items")

return function (event)
    local processed = false

    for i = 1, 8 do
        local ret
        -- Knob 1 on the SL sends control change events on channel 16 with CC# 21 (0x15)
        -- value is:
        -- * 1-16 for clockwise turns, depending on speed (1 slowest)
        -- * 127-112 for counter-clockwise turns, depending on speed (127 slowest)

        -- remote.match_midi is a utility function that creates a MIDI event from a string mask and variables.
        -- mask should be a string containing the MIDI mask. It may contain variable references (x,y
        -- and z).
        ret = remote.match_midi(items["knob" .. i].midiMatcher, event)
        if ret and stateUtils.get("knob" .. i .. ".enabled") then
            local delta = ret.x <= 63 and ret.x or ret.x - 128
            stateUtils.add("knob" .. i .. ".value", delta, 0, 127)

            -- CODEC => REASON
            remote.handle_input({
                item = items["knob" .. i].index,
                value = delta,
                time_stamp = event.time_stamp
            })
            processed = true
        end

        ret = remote.match_midi(items["button" .. i].midiMatcher, event)
        if ret and stateUtils.get("button" .. i .. ".enabled") and ret.x > 0 then
            stateUtils.flip("button" .. i .. ".value")

            -- CODEC => REASON
            remote.handle_input({
                item = items["button" .. i].index,
                value = stateUtils.getNext("button" .. i .. ".value") and 127 or 0,
                time_stamp = event.time_stamp
            })
            processed = true
        end
    end

    return processed
end
