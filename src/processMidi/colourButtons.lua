local stateUtils = require("lib.stateUtils")
local debugUtils = require("lib.debugUtils")
local hexUtils = require("lib.hexUtils")

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
    if stateUtils.hasChanged("buttonColour") then
        local colour = stateUtils.getNext("buttonColour")
        debugUtils.log("button colour changed: " .. colour .. " 0x" .. hexUtils.decToHex(colour))
    end
    return true
end
