local stateUtils = require("src.lib.stateUtils")
local items = require("src.lib.items")
local log = require("src.lib.debugUtils").log

return function(changedItems)
    for _, changedItemIndex in ipairs(changedItems) do
        if changedItemIndex == items.deviceType.index then
            local deviceType = remote.get_item_text_value(changedItemIndex)
            log("device type: " .. deviceType)
            stateUtils.set("deviceType", deviceType)
            return
        end
    end
end
