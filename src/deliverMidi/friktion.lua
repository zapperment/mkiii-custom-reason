local stateUtils = require("lib.stateUtils")
--local debugUtils = require("lib.debugUtils")
local handleInputQueue = require("lib.handleInputQueue")

return function()
    local deviceTypeChangedToFriktion = stateUtils.hasChanged("deviceType") and stateUtils.getNext("deviceType") == "friktion"
    local patchOfFriktionDeviceChanged = stateUtils.hasChanged("patchName") and not stateUtils.hasChanged("deviceType") and stateUtils.get("deviceType") == "friktion"

    if not deviceTypeChangedToFriktion and not patchOfFriktionDeviceChanged then
        return
    end

    table.insert(handleInputQueue, { itemName = "friktionVibratoAssign", value = 120, countDown = 20 })
    table.insert(handleInputQueue, { itemName = "friktionSustainAssign", value = 80, countDown = 20 })
end
