local stateUtils = require("src.lib.stateUtils")
local constants = require("src.lib.constants")
local faderStates = require("src.lib.faderStates")

function resetState()
    for i = 1, 8 do
        stateUtils.set("knob" .. i .. ".label", " ")
        stateUtils.set("knob" .. i .. ".value", 0)
        stateUtils.set("knob" .. i .. ".enabled", false)
        stateUtils.set("button" .. i .. ".label", " ")
        stateUtils.set("button" .. i .. ".value", 0)
        stateUtils.set("button" .. i .. ".enabled", false)
        stateUtils.set("fader" .. i, faderStates.unassigned)
    end
    stateUtils.set("deviceType", " ")
    stateUtils.set("deviceName", " ")
    stateUtils.set("patchName", " ")
    stateUtils.set("buttonColour", constants.mainColour)
    stateUtils.set("layer", " ")
    stateUtils.updateAll()
end

return {
    resetState = resetState
}
