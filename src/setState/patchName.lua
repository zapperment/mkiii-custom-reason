local stateUtils = require("lib.stateUtils")
local combinatorUtils = require("lib.combinatorUtils")
local items = require("lib.items")

-- Unlike the other setState functions, this one returns a boolean that indicates if we use custom labels defined in
-- lib.combinators; we need this in the setState function for the knob and button labels
return function (changedItems)
    for _, changedItemIndex in ipairs(changedItems) do
        if changedItemIndex == items.patchName.index then
            stateUtils.set("patchName", remote.get_item_text_value(changedItemIndex))
            local combinatorConfig = combinatorUtils.getCombinatorConfig()
            if combinatorConfig then
                combinatorUtils.assignConfig(combinatorConfig)
                return true
            else
                combinatorUtils.resetConfig(combinatorConfig)
                return false
            end
        end
    end
    return false
end
