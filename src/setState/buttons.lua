local stateUtils = require("lib.stateUtils")
local items = require("lib.items")

return function (changedItems, hasCustomLabels)
    for _, changedItemIndex in ipairs(changedItems) do
        local changedItem = remote.get_item_state(changedItemIndex)
        for i = 1, 8 do
            local button = "button" .. i
            if changedItemIndex == items[button].index then
                if changedItem.is_enabled then
                    if hasCustomLabels == false then
                        stateUtils.set(button .. ".label", changedItem.short_name)
                    end
                    stateUtils.set(button .. ".value", changedItem.value > 0)
                    stateUtils.set(button .. ".enabled", true)
                else
                    stateUtils.set(button .. ".label", "")
                    stateUtils.set(button .. ".value", false)
                    stateUtils.set(button .. ".enabled", false)
                end
            end
        end
    end
end
