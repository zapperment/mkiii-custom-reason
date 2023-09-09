local stateUtils = require("src.lib.stateUtils")
local items = require("src.lib.items")
local combinatorUtils = require("src.lib.combinatorUtils")

return function(changedItems)
    local combinatorConfig = combinatorUtils.getCombinatorConfig()
    local hasCustomLabels = combinatorConfig ~= nil
    for _, changedItemIndex in ipairs(changedItems) do
        local changedItem = remote.get_item_state(changedItemIndex)
        for i = 1, 8 do
            local knob = "knob" .. i
            if changedItemIndex == items[knob].index then
                if changedItem.is_enabled then
                    if hasCustomLabels then
                        stateUtils.set(knob .. ".label", combinatorConfig[knob] or "")
                    else
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
