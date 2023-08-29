local items = require("lib.items")
local stateUtils = require("lib.stateUtils")

return function(event)
    ret = remote.match_midi(items.footSwitch.midiMatcher, event)
    if ret and ret.x > 0 then
        stateUtils.flip("footSwitch")
        remote.handle_input({
            item = items["footSwitch"].index,
            value = stateUtils.getNext("footSwitch") and 127 or 0,
            time_stamp = event.time_stamp
        })
        return true
    end
    return false
end
