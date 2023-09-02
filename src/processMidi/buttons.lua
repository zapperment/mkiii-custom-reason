local stateUtils = require("lib.stateUtils")
local debugUtils = require("lib.debugUtils")
local items = require("lib.items")

return function(event)
    local processed = false

    for i = 1, 8 do
        local ret = remote.match_midi(items["button" .. i].midiMatcher, event)
        if ret and stateUtils.get("button" .. i .. ".enabled") and ret.x > 0 then
            stateUtils.flip("button" .. i .. ".value")

            -- CODEC => REASON
            remote.handle_input({
                item = items["button" .. i].index,
                value = 127,
                time_stamp = event.time_stamp
            })
            processed = true
        end
    end

    return processed
end
