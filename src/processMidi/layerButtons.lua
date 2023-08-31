local stateUtils = require("lib.stateUtils")
local items = require("lib.items")
local constants = require("lib.constants")

return function(event)
    local processed = false
    for _, button in ipairs({"buttonLayerA", "buttonLayerB"}) do
        local ret = remote.match_midi(items[button].midiMatcher, event)
        if ret and ret.x > 0 then
            local layer = button == "buttonLayerA" and constants.layerA or constants.layerB
            stateUtils.set("layer", layer)

            remote.handle_input({
                item = items[button].index,
                value = 1,
                time_stamp = event.time_stamp
            })
            processed = true
        end
    end
    return processed
end
