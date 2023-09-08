local stateUtils = require("lib.stateUtils")
local debugUtils = require("lib.debugUtils")
local handleInputQueue = require("lib.handleInputQueue")

return function()
    local deviceTypeChangedToFriktion = stateUtils.hasChanged("deviceType") and stateUtils.getNext("deviceType") == "friktion"
    local patchOfFriktionDeviceChanged = stateUtils.hasChanged("patchName") and not stateUtils.hasChanged("deviceType") and stateUtils.get("deviceType") == "friktion"

    if not deviceTypeChangedToFriktion and not patchOfFriktionDeviceChanged then
        return
    end

    if deviceTypeChangedToFriktion then
        debugUtils.log("Device type changed to Friktion")
    end

    if patchOfFriktionDeviceChanged then
        debugUtils.log("Patch of Friktion device changed")
    end

    table.insert(handleInputQueue, { itemName = "friktionVibratoAssign", value = 120, delay = 100000 })
    table.insert(handleInputQueue, { itemName = "friktionSustainAssign", value = 80, delay = 100000 })
end
