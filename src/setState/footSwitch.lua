local stateUtils = require("lib.stateUtils")
local items = require("lib.items")

return function(changedItems)
    for _, changedItemIndex in ipairs(changedItems) do
        local changedItem = remote.get_item_state(changedItemIndex)
        if changedItemIndex == items.footSwitch.index then
            stateUtils.set("footSwitch", changedItem.value > 0)
        end
    end
end
