local stateUtils = require("src.lib.stateUtils")
local items = require("src.lib.items")
local constants = require("src.lib.constants")
-- local log = require("src.lib.debugUtils").log

return function(event)
    local processed = false
    local ret = remote.match_midi(items.shiftButton.midiMatcher, event)
    if ret then
        isShifted = ret.x > 0
        processed = true
    end
    return processed
end

