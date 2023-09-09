local stateUtils = require("src.lib.stateUtils")
local items = require("src.lib.items")

return function(changedItems)
    for _, changedItemIndex in ipairs(changedItems) do
        if changedItemIndex == items.deviceName.index then
            stateUtils.set("deviceName", remote.get_item_text_value(changedItemIndex))
            return
        end
    end
end
