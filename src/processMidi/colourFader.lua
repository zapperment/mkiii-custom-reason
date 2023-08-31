local stateUtils = require("lib.stateUtils")

-- DELETE ME: fader 1 controls button colour – just for experimentation
return function(event)
    ret = remote.match_midi("BF 29 xx", event)
    if ret then
        stateUtils.set("buttonColour", ret.x)
        stateUtils.set("patchName", "buttonColour=" .. tostring(ret.x))
        return true
    end
    return false
end
