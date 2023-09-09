local stateUtils = require("src.lib.stateUtils")
-- local debugUtils = require("src.lib.debugUtils")

return function(event)
    local up = remote.match_midi("BF 53 7F", event)
    local down = remote.match_midi("BF 54 7F", event)
    if up == nil and down == nil then
        return false
    end
    if up then
        stateUtils.inc("buttonColour")
    end
    if down then
        stateUtils.dec("buttonColour")
    end
    return true
end
