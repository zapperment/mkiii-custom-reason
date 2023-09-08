local stateUtils = require("lib.stateUtils")
local items = require("lib.items")
local debugUtils = require("lib.debugUtils")

return function(changedItems)
    for _, changedItemIndex in ipairs(changedItems) do
        if changedItemIndex == items.deviceType.index then
            local deviceType = remote.get_item_text_value(changedItemIndex);
            stateUtils.set("deviceType", deviceType)
            return
        end
    end
end
