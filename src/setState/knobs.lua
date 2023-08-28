local stateUtils = require("lib.stateUtils")
local items = require("lib.items")

return function (changedItems, hasCustomLabels)
    for _, changedItemIndex in ipairs(changedItems) do
        local changedItem = remote.get_item_state(changedItemIndex)
        for i = 1, 8 do
            local knob = "knob" .. i
            if changedItemIndex == items[knob].index then
                if changedItem.is_enabled then
                    if hasCustomLabels == false then
                        stateUtils.set(knob .. ".label", changedItem.short_name)
                    end
                    stateUtils.set(knob .. ".value", changedItem.value)
                    stateUtils.set(knob .. ".enabled", true)
                else
                    stateUtils.set(knob .. ".label", "")
                    stateUtils.set(knob .. ".value", 0)
                    stateUtils.set(knob .. ".enabled", false)
                end
            end
        end
    end
end
