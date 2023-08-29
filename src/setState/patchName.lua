local stateUtils = require("lib.stateUtils")
local combinatorUtils = require("lib.combinatorUtils")
local items = require("lib.items")

return function (changedItems)
    for _, changedItemIndex in ipairs(changedItems) do
        if changedItemIndex == items.patchName.index then
            stateUtils.set("patchName", remote.get_item_text_value(changedItemIndex))
            local combinatorConfig = combinatorUtils.getCombinatorConfig()
            if combinatorConfig then
                combinatorUtils.assignConfig(combinatorConfig)
            end
        end
    end
end
